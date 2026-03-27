import os
import csv
import sys
import time
import requests
import threading
from urllib.parse import urlparse, parse_qs
from concurrent.futures import ThreadPoolExecutor, as_completed
from bs4 import BeautifulSoup
from deep_translator import GoogleTranslator

# Các headers giả lập trình duyệt để tránh bị chặn IP bởi cơ chế bảo vệ của Oxford
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/120.0.0.0 Safari/537.36'
}

# Sử dụng Session để giữ kết nối TCP (tránh lỗi cạn kiệt cổng Errno 49 trên macOS)
session = requests.Session()
adapter = requests.adapters.HTTPAdapter(pool_connections=15, pool_maxsize=15, max_retries=3)
session.mount('http://', adapter)
session.mount('https://', adapter)
session.headers.update(HEADERS)

def get_html(url, timeout=15):
    response = session.get(url, timeout=timeout)
    response.raise_for_status()
    return response.text

def parse_word_detail(word_url):
    html = get_html(word_url)
    soup = BeautifulSoup(html, 'html.parser')
    
    # Lấy phân loại từ (part of speech)
    pos_tag = soup.find('span', class_='pos')
    part_of_speech = pos_tag.get_text(strip=True) if pos_tag else ''
    
    # Lấy phiên âm (IPA)
    phon_tag = soup.find('span', class_='phon')
    ipa = phon_tag.get_text(strip=True) if phon_tag else ''
    
    # Lấy cấp độ (Level) từ icon chìa khoá (A1, B2...)
    level = ''
    level_tag = soup.find(class_='symbols')
    if level_tag and level_tag.find('a'):
        href = level_tag.find('a').get('href', '')
        if 'level=' in href:
            level = href.split('level=')[-1].upper()
            
    # Fallback cho trường hợp thẻ bị đổi cấu trúc
    if not level:
        for a in soup.find_all('a'):
            href = a.get('href', '')
            if 'level=' in href and len(href.split('level=')[-1]) == 2:
                level = href.split('level=')[-1].upper()
                break
            
    # Lấy Audio link (ưu tiên icon loa màu xanh / UK, đổi class nếu cần)
    audio_link = ''
    audio_tag = soup.find('div', class_='sound audio_play_button')
    if audio_tag and audio_tag.has_attr('data-src-mp3'):
        audio_link = audio_tag['data-src-mp3']
        if not audio_link.startswith('http'):
            audio_link = 'https://www.oxfordlearnersdictionaries.com' + audio_link
            
    return part_of_speech, ipa, level, audio_link

def scrape_topic(topic_url, output_csv):
    print(f"Đang quét trang chủ đề: {topic_url} ...")
    try:
        html = get_html(topic_url)
    except Exception as e:
        print(f"Lỗi truy cập trang chủ đề: {e}")
        return

    soup = BeautifulSoup(html, 'html.parser')
    
    # Phân tích URL để tìm xem trang này có phải là danh sách con (sublist) không
    parsed_url = urlparse(topic_url)
    qs = parse_qs(parsed_url.query)
    sublist_id = qs.get('sublist', [None])[0]
    
    # Trong trang Topic của Oxford, các từ vựng thường nằm trong thẻ <li> có thuộc tính data-hw
    li_tags = soup.find_all('li', attrs={'data-hw': True})
    
    # Lọc các thẻ li nếu có tham số sublist
    if sublist_id:
        filter_attr = 'data-' + sublist_id
        li_tags = [li for li in li_tags if li.has_attr(filter_attr)]
        
    word_links = []
    for li in li_tags:
        a_tag = li.find('a')
        if a_tag:
            # Lấy level ngay trong lúc duyệt topic
            level_from_topic = ''
            belong_tag = li.find('span', class_='belong-to')
            if belong_tag:
                level_from_topic = belong_tag.get_text(strip=True).upper()
            word_links.append((a_tag, level_from_topic))
            
    if not word_links:
        print("Không tìm thấy từ vựng nào trên trang này. Hãy kiểm tra lại URL.")
        return

    print(f"Tìm thấy {len(word_links)} từ vựng. Bắt đầu quá trình quét đa luồng...")
    
    # Chuẩn bị file CSV và ghi Header trước
    os.makedirs(os.path.dirname(output_csv), exist_ok=True)
    with open(output_csv, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'id', 'url', 'levels', 'word', 'translation', 'part_of_speech', 'ipa', 'audio_link'
        ])
        writer.writeheader()

    csv_lock = threading.Lock()
    completed_count = [0]
    total_words = len(word_links)

    def process_word(item):
        link, level_from_topic = item
        word = link.get_text(strip=True)
        word_url = link.get('href')
        
        if not word_url:
            return
            
        if word_url.startswith('/'):
            word_url = 'https://www.oxfordlearnersdictionaries.com' + word_url
            
        if not word_url.startswith('http'):
             return
             
        word_id = word.replace(' ', '_').lower()
        
        try:
            pos, ipa, level, audio = parse_word_detail(word_url)
            
            # Ưu tiên level từ trang Topic (vì đôi khi từ đồng âm nhưng ở topic này thì yêu cầu level khác)
            if not level and level_from_topic:
                level = level_from_topic
            elif level_from_topic:
                level = level_from_topic

            try:
                translation = GoogleTranslator(source='en', target='vi').translate(word)
            except:
                translation = ''
                
            row_data = {
                'id': word_id,
                'url': word_url,
                'levels': level,
                'word': word,
                'translation': translation,
                'part_of_speech': pos,
                'ipa': ipa,
                'audio_link': audio
            }
            
            # Ghi ngay vào file (Lock để không bị conflict giữa các luồng)
            with csv_lock:
                with open(output_csv, 'a', newline='', encoding='utf-8') as f:
                    writer = csv.DictWriter(f, fieldnames=[
                        'id', 'url', 'levels', 'word', 'translation', 'part_of_speech', 'ipa', 'audio_link'
                    ])
                    writer.writerow(row_data)
                
                completed_count[0] += 1
                sys.stdout.write(f"\rĐã xử lý: {completed_count[0]}/{total_words} - Xong từ: {word}" + " " * 20)
                sys.stdout.flush()
                
            time.sleep(0.5)  # Tránh spam server quá nhanh
                
        except Exception as e:
            with csv_lock:
                print(f"\n[LỖI] {word}: {e}")

    # Chạy đa luồng (Tối đa 10 luồng cùng lúc để giữ an toàn không bị block IP)
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(process_word, item) for item in word_links]
        for future in as_completed(futures):
            # Lấy exception nếu có lỗi không bắt được trong hàm
            if future.exception() is not None:
                pass

    print(f"\nHoàn tất! Đã quét xong mảng từ vựng vào {output_csv}")

def scrape_category(category_url, output_dir):
    print(f"Bắt đầu phân tích danh mục lớn: {category_url}")
    try:
        html = get_html(category_url)
    except Exception as e:
        print(f"Lỗi: {e}")
        return
        
    soup = BeautifulSoup(html, 'html.parser')
    sublists = []
    
    # Các nhóm chủ đề con thường nằm trong topic-box hoặc list-col
    ul = soup.find('ul', class_='topic-box') or soup.find('ul', class_='list-col')
    if ul:
        for a in ul.find_all('a'):
            href = a.get('href', '')
            if 'sublist=' in href:
                name = a.get('title') or a.get_text()
                # Cần ghép domain vào link nếu chưa có
                if href.startswith('/'):
                    href = 'https://www.oxfordlearnersdictionaries.com' + href
                sublists.append({'url': href, 'name': name.strip()})
    else:
        for a in soup.find_all('a'):
            href = a.get('href', '')
            if 'sublist=' in href:
                if href.startswith('/'):
                    href = 'https://www.oxfordlearnersdictionaries.com' + href
                sublists.append({'url': href, 'name': a.get_text().strip()})
                
    # Lọc trùng lặp
    unique_sublists = []
    seen = set()
    for s in sublists:
        if s['url'] not in seen:
            seen.add(s['url'])
            unique_sublists.append(s)
            
    if not unique_sublists:
        print("Không tìm thấy các nhóm chủ đề con nào!")
        return
        
    print(f"Tìm thấy {len(unique_sublists)} nhóm con. Bắt đầu tải từng nhóm...")
    for sub in unique_sublists:
        safe_name = sub['name'].replace('/', '_').replace(':', '') + '.csv'
        out_csv = os.path.join(output_dir, safe_name)
        
        print(f"\n--- NHÓM: {sub['name']} ---")
        scrape_topic(sub['url'], out_csv)

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Cách dùng:")
        print("  Cách 1 (Tải 1 link): python scripts/scrape_topic.py <Link-Chủ-Đề-Oxford> <File-Đích>")
        print("  Cách 2 (Tải nhóm):   python scripts/scrape_topic.py <Link-Danh-Mục-Lớn> <Thư-Mục-Đích>")
        print("\nVí dụ chia nhóm: python scripts/scrape_topic.py https://www.oxfordlearnersdictionaries.com/topic/category/animals_1 assets/data/topic/Animals")
        sys.exit(1)
        
    target_url = sys.argv[1]
    output_tgt = sys.argv[2]
    
    if '/category/' in target_url:
        scrape_category(target_url, output_tgt)
    else:
        scrape_topic(target_url, output_tgt)
