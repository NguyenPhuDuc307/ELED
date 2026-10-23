import type { GrammarUnit } from "./types";

// Nhóm "complex": các cấu trúc câu phức giúp nâng điểm Grammatical Range and Accuracy lên band 6.0.

export const complex: GrammarUnit[] = [
  // ---------------------------------------------------------------------------
  // 1. Mệnh đề quan hệ
  // ---------------------------------------------------------------------------
  {
    id: "relative-clauses",
    group: "complex",
    band: "6.0",
    title: "Mệnh đề quan hệ",
    en: "Relative Clauses",
    summary:
      "Mệnh đề quan hệ (relative clause) giúp gộp hai ý thành một câu phức, bổ sung thông tin cho danh từ mà không phải lặp lại. Đây là cách nhanh và an toàn nhất để có câu phức chính xác trong cả Writing lẫn Speaking.",
    rules: [
      {
        title: "Mệnh đề xác định và không xác định (defining vs non-defining)",
        body:
          "Mệnh đề xác định cho biết đang nói về người/vật nào, không có dấu phẩy và có thể dùng that. Mệnh đề không xác định chỉ thêm thông tin phụ về danh từ đã rõ, phải đặt giữa hai dấu phẩy và không bao giờ dùng that.",
        form: "Xác định: N + who/which/that + V… | Không xác định: N, who/which + V…, …",
        examples: [
          {
            en: "Students **who study abroad** often become more independent.",
            vi: "Những sinh viên đi du học thường trở nên tự lập hơn.",
          },
          {
            en: "The policy **that the government introduced last year** has reduced traffic congestion.",
            vi: "Chính sách mà chính phủ ban hành năm ngoái đã giảm được ùn tắc giao thông.",
          },
          {
            en: "Hanoi, **which is the capital of Vietnam**, has a population of over eight million.",
            vi: "Hà Nội, thủ đô của Việt Nam, có dân số hơn tám triệu người.",
          },
        ],
      },
      {
        title: "Chọn đại từ quan hệ: who, which, that, whose, where, when",
        body:
          "Who thay cho người, which cho vật, that cho cả hai (chỉ trong mệnh đề xác định). Whose chỉ sở hữu và luôn đi kèm danh từ; where thay cho nơi chốn, when thay cho thời gian.",
        form: "who (người) | which (vật) | whose + N (sở hữu) | where = in/at which | when = in/on which",
        examples: [
          {
            en: "Employees **whose salaries are low** are more likely to change jobs.",
            vi: "Những nhân viên có lương thấp dễ nhảy việc hơn.",
          },
          {
            en: "Cities **where public transport is cheap** tend to have cleaner air.",
            vi: "Những thành phố có giao thông công cộng rẻ thường có không khí sạch hơn.",
          },
          {
            en: "2008 was the year **when** the global financial crisis began.",
            vi: "2008 là năm cuộc khủng hoảng tài chính toàn cầu bắt đầu.",
          },
        ],
      },
      {
        title: "Giới từ + which/whom (preposition + relative pronoun)",
        body:
          "Trong văn viết trang trọng, giới từ được đưa lên trước which (vật) hoặc whom (người). Sau giới từ không được dùng that hay who.",
        form: "N + giới từ + which/whom + S + V",
        examples: [
          {
            en: "The extent **to which** technology improves learning is still debated.",
            vi: "Mức độ mà công nghệ cải thiện việc học vẫn còn gây tranh cãi.",
          },
          {
            en: "Climate change is an issue **on which** most scientists agree.",
            vi: "Biến đổi khí hậu là vấn đề mà hầu hết các nhà khoa học đều đồng thuận.",
          },
          {
            en: "The colleagues **with whom** I work are very supportive.",
            vi: "Những đồng nghiệp làm việc cùng tôi rất hay giúp đỡ.",
          },
        ],
      },
      {
        title: "Which thay cho cả mệnh đề phía trước",
        body:
          "Đặt dấu phẩy rồi dùng which để nói về hệ quả hoặc nhận xét cho toàn bộ ý vừa nêu, không phải cho một danh từ. Trường hợp này bắt buộc dùng which, không dùng that hay what.",
        form: "Mệnh đề, which + V (số ít)…",
        examples: [
          {
            en: "The number of private cars rose sharply, **which caused serious air pollution**.",
            vi: "Số ô tô cá nhân tăng mạnh, điều này gây ô nhiễm không khí nghiêm trọng.",
          },
          {
            en: "Many graduates move abroad after university, **which puts pressure on the domestic labour market**.",
            vi: "Nhiều sinh viên ra nước ngoài sau khi tốt nghiệp, điều đó gây áp lực lên thị trường lao động trong nước.",
          },
        ],
      },
      {
        title: "Rút gọn mệnh đề quan hệ (reduced relative clauses)",
        body:
          "Khi đại từ quan hệ làm chủ ngữ, có thể bỏ đại từ và trợ động từ: dùng V-ing nếu nghĩa chủ động, V3 nếu nghĩa bị động. Cách này làm câu gọn và mang tính học thuật hơn.",
        form: "N + V-ing (chủ động) | N + V3 (bị động)",
        examples: [
          {
            en: "People **living in rural areas** have limited access to healthcare.",
            vi: "Người dân sống ở nông thôn ít được tiếp cận dịch vụ y tế.",
          },
          {
            en: "The data **collected from the survey** reveal a clear trend.",
            vi: "Dữ liệu thu thập được từ cuộc khảo sát cho thấy một xu hướng rõ ràng.",
          },
          {
            en: "Most of the products **sold online** are delivered within two days.",
            vi: "Phần lớn sản phẩm bán trực tuyến được giao trong vòng hai ngày.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip:
          "Dùng \", which…\" để nối một ý với hệ quả của nó thay vì viết hai câu đơn rời rạc. Giám khảo ghi nhận câu phức dùng đúng (kể cả dấu phẩy) như bằng chứng về độ đa dạng ngữ pháp; chỉ cần vài câu như vậy trong bài, đừng nhồi vào mọi câu.",
        example:
          "Many young people now work remotely, which allows them to save both time and money on commuting.",
      },
      {
        part: "Writing Task 1",
        tip:
          "Chèn mệnh đề không xác định để đưa thêm số liệu vào cùng một câu, hoặc rút gọn mệnh đề (V-ing/V3) để mô tả nhóm đối tượng. Câu vừa gọn vừa giàu thông tin, tránh chuỗi câu đơn lặp cấu trúc.",
        example:
          "The figure for coal, which stood at 40% in 1990, fell to just 15% by 2020, while the proportion of households owning a car doubled.",
      },
      {
        part: "Speaking",
        tip:
          "Trong Part 2, dùng where/when/who để miêu tả nơi chốn, thời điểm, con người một cách tự nhiên. Mệnh đề xác định ngắn, nói trôi chảy, có giá trị hơn một câu dài nhưng sai.",
        example: "It's a small café where I usually study at weekends, and the owner, who is a retired teacher, always chats with me.",
      },
    ],
    mistakes: [
      {
        wrong: "My father, that is a doctor, works in Hue.",
        right: "My father, who is a doctor, works in Hue.",
        note: "Mệnh đề không xác định (có dấu phẩy) không được dùng that.",
      },
      {
        wrong: "The book which I bought it yesterday is very useful.",
        right: "The book which I bought yesterday is very useful.",
        note: "Which đã thay cho tân ngữ nên không lặp lại it.",
      },
      {
        wrong: "This is the city where I was born in.",
        right: "This is the city where I was born. / This is the city in which I was born.",
        note: "Where đã bao hàm giới từ in, thêm in nữa là thừa.",
      },
      {
        wrong: "The man who his car was stolen called the police.",
        right: "The man whose car was stolen called the police.",
        note: "Chỉ sở hữu phải dùng whose, không ghép who + his.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Students ___ parents are well educated tend to perform better at school.",
        options: ["who", "whose", "which", "whom"],
        answer: 1,
        explain:
          "Cần chỉ sở hữu (cha mẹ của các học sinh) và ngay sau chỗ trống là danh từ parents, nên dùng whose. Who/whom không đi trực tiếp với danh từ chỉ sở hữu.",
      },
      {
        type: "choice",
        q: "Ho Chi Minh City, ___ is the largest city in Vietnam, faces serious flooding problems.",
        options: ["that", "where", "which", "what"],
        answer: 2,
        explain:
          "Đây là mệnh đề không xác định (có hai dấu phẩy) và đóng vai chủ ngữ cho is, nên dùng which. That không được dùng sau dấu phẩy; where cần một mệnh đề đầy đủ chủ ngữ phía sau.",
      },
      {
        type: "choice",
        q: "The extent to ___ social media affects mental health is still unclear.",
        options: ["which", "that", "whom", "what"],
        answer: 0,
        explain:
          "Sau giới từ to chỉ dùng which (vật) hoặc whom (người). Social media là vật nên chọn which; that không bao giờ đứng sau giới từ.",
      },
      {
        type: "choice",
        q: "Many factories were built along the river, ___ caused serious water pollution.",
        options: ["that", "what", "it", "which"],
        answer: 3,
        explain:
          "Ý \"gây ô nhiễm\" nói về toàn bộ việc xây nhà máy, nên dùng \", which\" thay cho cả mệnh đề. That không dùng sau dấu phẩy; dùng it sẽ tạo lỗi nối hai mệnh đề bằng dấu phẩy (comma splice).",
      },
      {
        type: "choice",
        q: "Chọn câu đúng:",
        options: [
          "The company, which was founded in 1995, now employs 2,000 people.",
          "The company, that was founded in 1995, now employs 2,000 people.",
          "The company which was founded in 1995 it now employs 2,000 people.",
          "The company, was founded in 1995, now employs 2,000 people.",
        ],
        answer: 0,
        explain:
          "Mệnh đề không xác định dùng which giữa hai dấu phẩy. Phương án dùng that sai vì có dấu phẩy; phương án có it lặp chủ ngữ; phương án cuối thiếu đại từ quan hệ.",
      },
      {
        type: "choice",
        q: "People ___ in big cities often suffer from high levels of stress.",
        options: ["live", "lived", "living", "are living"],
        answer: 2,
        explain:
          "Đây là mệnh đề quan hệ rút gọn của \"who live\" mang nghĩa chủ động, nên dùng V-ing: living. Lived là dạng rút gọn bị động; live/are living làm câu có hai động từ chính.",
      },
      {
        type: "fill",
        q: "Countries ___ economies depend heavily on tourism were badly affected by the pandemic.",
        hint: "(đại từ quan hệ chỉ sở hữu)",
        answers: ["whose"],
        explain:
          "Kinh tế \"của các quốc gia\" là quan hệ sở hữu và theo sau là danh từ economies, nên chỉ có whose là đúng; which hay that không đi kèm danh từ theo cách này.",
      },
      {
        type: "fill",
        q: "The village ___ my grandparents live has no hospital.",
        hint: "(nơi chốn)",
        answers: ["where", "in which"],
        explain:
          "Live cần giới từ in (live in the village), nên dùng where hoặc in which. Dùng which/that đơn lẻ là sai vì thiếu giới từ in ở cuối mệnh đề.",
      },
      {
        type: "fill",
        q: "Most of the goods ___ in this factory are exported to Europe.",
        hint: "(produce)",
        answers: ["produced", "which are produced", "that are produced"],
        explain:
          "Hàng hoá \"được sản xuất\" mang nghĩa bị động, nên rút gọn thành V3: produced (= which are produced). Producing sai vì hàng hoá không tự sản xuất.",
      },
      {
        type: "fill",
        q: "Workers ___ more than 50 hours a week are at higher risk of heart disease.",
        hint: "(work)",
        answers: ["working", "who work", "that work"],
        explain:
          "Người lao động tự làm việc nên nghĩa chủ động: rút gọn thành working hoặc giữ đầy đủ who/that work. Worked sai vì mang nghĩa bị động.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 2. Câu điều kiện
  // ---------------------------------------------------------------------------
  {
    id: "conditionals",
    group: "complex",
    band: "6.0",
    title: "Câu điều kiện",
    en: "Conditionals",
    summary:
      "Câu điều kiện (conditional sentences) diễn đạt nguyên nhân – kết quả, giả định và hối tiếc. Trong IELTS, đây là công cụ chính để đề xuất giải pháp ở Writing Task 2 và trả lời câu hỏi giả định ở Speaking.",
    rules: [
      {
        title: "Câu điều kiện loại 0 và loại 1 (zero & first conditional)",
        body:
          "Loại 0 nói về sự thật, quy luật luôn đúng: hai vế đều ở hiện tại đơn. Loại 1 nói về khả năng có thật ở hiện tại hoặc tương lai: vế if dùng hiện tại đơn, vế chính dùng will/can/may; không dùng will trong vế if.",
        form: "Loại 0: If + S + V(hiện tại), S + V(hiện tại) | Loại 1: If + S + V(hiện tại), S + will/can/may + V",
        examples: [
          {
            en: "If water **is heated** to 100°C, it **boils**.",
            vi: "Nếu nước được đun tới 100°C, nó sôi.",
          },
          {
            en: "If people **don't get** enough sleep, their concentration **suffers**.",
            vi: "Nếu không ngủ đủ, khả năng tập trung sẽ bị ảnh hưởng.",
          },
          {
            en: "If the government **invests** more in public transport, fewer people **will drive** to work.",
            vi: "Nếu chính phủ đầu tư nhiều hơn cho giao thông công cộng, sẽ có ít người lái xe đi làm hơn.",
          },
        ],
      },
      {
        title: "Câu điều kiện loại 2 (second conditional)",
        body:
          "Diễn tả tình huống giả định, không có thật hoặc khó xảy ra ở hiện tại/tương lai. Vế if lùi về quá khứ đơn; với to be, văn trang trọng dùng were cho mọi ngôi.",
        form: "If + S + V2/were, S + would/could/might + V",
        examples: [
          {
            en: "If university **were** free, more students from poor families **would continue** their education.",
            vi: "Nếu đại học miễn phí, nhiều sinh viên nghèo hơn sẽ tiếp tục học lên.",
          },
          {
            en: "If I **had** more free time, I **would learn** another language.",
            vi: "Nếu có nhiều thời gian rảnh hơn, tôi sẽ học thêm một ngoại ngữ.",
          },
        ],
      },
      {
        title: "Câu điều kiện loại 3 (third conditional)",
        body:
          "Giả định trái với sự thật trong quá khứ, thường để nói về hối tiếc hoặc phân tích nguyên nhân. Vế if dùng quá khứ hoàn thành, vế chính dùng would/could/might + have + V3.",
        form: "If + S + had + V3, S + would/could/might + have + V3",
        examples: [
          {
            en: "If the city **had built** a metro system earlier, traffic congestion **would not have become** so severe.",
            vi: "Nếu thành phố xây tàu điện ngầm sớm hơn thì ùn tắc đã không trầm trọng đến vậy.",
          },
          {
            en: "If I **had studied** harder at school, I **could have entered** a better university.",
            vi: "Nếu hồi đi học tôi chăm hơn thì đã có thể vào một trường đại học tốt hơn.",
          },
        ],
      },
      {
        title: "Câu điều kiện hỗn hợp (mixed conditional)",
        body:
          "Kết hợp hai mốc thời gian: điều kiện trong quá khứ dẫn đến kết quả ở hiện tại, hoặc một đặc điểm hiện tại giải thích kết quả trong quá khứ.",
        form: "If + S + had + V3, S + would + V (hiện tại) | If + S + V2/were, S + would have + V3 (quá khứ)",
        examples: [
          {
            en: "If I **had chosen** engineering, I **would be earning** much more now.",
            vi: "Nếu hồi đó tôi chọn ngành kỹ thuật thì bây giờ đã kiếm được nhiều hơn nhiều.",
          },
          {
            en: "If she **were** more confident, she **would have applied** for the promotion last year.",
            vi: "Nếu cô ấy tự tin hơn thì năm ngoái đã nộp đơn xin thăng chức rồi.",
          },
        ],
      },
      {
        title: "Unless, provided (that), as long as, otherwise",
        body:
          "Unless nghĩa là \"nếu không\" nên vế sau unless không dùng phủ định nữa. Provided/providing (that) và as long as nghĩa là \"miễn là\", nhấn mạnh điều kiện bắt buộc; otherwise (\"nếu không thì\") đứng đầu mệnh đề thứ hai.",
        form: "Unless + S + V (khẳng định) | provided (that) / as long as + S + V(hiện tại) | …; otherwise, S + will/would + V",
        examples: [
          {
            en: "**Unless** stricter laws are introduced, air pollution will continue to worsen.",
            vi: "Nếu không ban hành luật nghiêm hơn, ô nhiễm không khí sẽ tiếp tục trầm trọng.",
          },
          {
            en: "Remote working can be effective **as long as** employees manage their time well.",
            vi: "Làm việc từ xa có thể hiệu quả miễn là nhân viên quản lý tốt thời gian.",
          },
          {
            en: "Governments must act now; **otherwise**, the cost of climate change will rise dramatically.",
            vi: "Chính phủ phải hành động ngay; nếu không, cái giá của biến đổi khí hậu sẽ tăng vọt.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip:
          "Khi đề xuất giải pháp, dùng loại 2 cho biện pháp chưa được áp dụng (mang tính giả định), loại 1 cho biện pháp thực tế, dễ xảy ra. Câu điều kiện chia đúng thì ở cả hai vế là câu phức chính xác, đóng góp trực tiếp vào tiêu chí Grammatical Range and Accuracy.",
        example:
          "If governments imposed higher taxes on sugary drinks, consumption would fall and public health would improve.",
      },
      {
        part: "Writing",
        tip:
          "Thay if bằng provided that, as long as hoặc unless ở một vài chỗ để thể hiện vốn cấu trúc đa dạng hơn. Chỉ dùng khi chắc nghĩa: unless = if… not, nên đừng thêm phủ định sau nó.",
        example:
          "Online learning can be as effective as classroom teaching, provided that students are self-disciplined.",
      },
      {
        part: "Speaking",
        tip:
          "Câu hỏi Part 1/Part 3 dạng \"What would you do if…?\" là cơ hội dùng loại 2; khi kể chuyện quá khứ ở Part 2, thêm một câu loại 3 để nói về điều đáng tiếc. Chia đúng would + V và had + V3 quan trọng hơn nói dài.",
        example:
          "If I could live anywhere, I would probably choose Da Nang, because it's close to the sea and much less crowded.",
      },
    ],
    mistakes: [
      {
        wrong: "If I will have time, I will visit my grandparents.",
        right: "If I have time, I will visit my grandparents.",
        note: "Vế if của câu điều kiện loại 1 dùng hiện tại đơn, không dùng will.",
      },
      {
        wrong: "If I would have more money, I would buy a house.",
        right: "If I had more money, I would buy a house.",
        note: "Would chỉ nằm ở vế chính; vế if của loại 2 dùng quá khứ đơn.",
      },
      {
        wrong: "Unless you don't study, you will fail the exam.",
        right: "Unless you study, you will fail the exam. / If you don't study, you will fail the exam.",
        note: "Unless đã mang nghĩa phủ định (if… not), thêm don't sẽ thành phủ định kép.",
      },
      {
        wrong: "If the government had acted earlier, the problem would not become so serious.",
        right: "If the government had acted earlier, the problem would not have become so serious.",
        note: "Giả định trái quá khứ thì vế chính phải là would + have + V3.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "If the government ___ public transport, fewer people will use private cars.",
        options: ["will improve", "improves", "improved", "would improve"],
        answer: 1,
        explain:
          "Vế chính dùng will nên đây là loại 1: vế if chia hiện tại đơn (improves). Will improve sai vì không dùng will trong vế if; improved là của loại 2.",
      },
      {
        type: "choice",
        q: "If university education ___ free, more young people would apply.",
        options: ["is", "will be", "were", "had been"],
        answer: 2,
        explain:
          "Vế chính dùng would + V nên đây là loại 2: vế if dùng were. Had been là của loại 3 và sẽ đi với would have applied.",
      },
      {
        type: "choice",
        q: "If the factory ___ the safety rules, the accident would not have happened.",
        options: ["had followed", "followed", "has followed", "would follow"],
        answer: 0,
        explain:
          "Vế chính là would not have happened (trái với quá khứ), nên vế if dùng quá khứ hoàn thành: had followed. Followed chỉ dùng cho loại 2.",
      },
      {
        type: "choice",
        q: "___ stricter measures are taken, the number of road accidents will keep rising.",
        options: ["If", "Unless", "Provided that", "As long as"],
        answer: 1,
        explain:
          "Nghĩa là \"nếu không áp dụng biện pháp nghiêm hơn thì tai nạn sẽ tiếp tục tăng\", nên dùng unless (= if… not). If/provided that/as long as làm câu thành vô lý: có biện pháp thì tai nạn lại tăng.",
      },
      {
        type: "choice",
        q: "If I had studied medicine, I ___ as a doctor now.",
        options: ["would have worked", "will work", "would be working", "had worked"],
        answer: 2,
        explain:
          "Điều kiện ở quá khứ (had studied) nhưng kết quả ở hiện tại (now), nên dùng câu hỗn hợp: would + V (would be working). Would have worked sai vì nói về quá khứ, mâu thuẫn với now.",
      },
      {
        type: "choice",
        q: "Students should revise regularly; ___, they may forget what they have learned.",
        options: ["unless", "provided that", "if", "otherwise"],
        answer: 3,
        explain:
          "Otherwise (\"nếu không thì\") đứng đầu mệnh đề thứ hai, sau dấu chấm phẩy và trước dấu phẩy. Unless/if/provided that là liên từ, phải đi với một mệnh đề điều kiện chứ không đứng một mình như vậy.",
      },
      {
        type: "fill",
        q: "If people ___ too much sugar, they usually put on weight.",
        hint: "(eat)",
        answers: ["eat"],
        explain:
          "Đây là quy luật chung, vế chính ở hiện tại đơn (put on), nên dùng loại 0: vế if cũng ở hiện tại đơn (eat). Will eat sai vì không dùng will trong vế if; ate sẽ đòi vế chính là would.",
      },
      {
        type: "fill",
        q: "If more people ___ bicycles, the air in our cities would be much cleaner.",
        hint: "(use)",
        answers: ["used", "were using"],
        explain:
          "Vế chính dùng would be nên đây là loại 2: vế if chia quá khứ đơn (used). Use hoặc will use là cấu trúc loại 1, không khớp với would.",
      },
      {
        type: "fill",
        q: "If the company had invested in new technology, it ___ bankrupt.",
        hint: "(not go)",
        answers: ["would not have gone", "wouldn't have gone", "might not have gone"],
        explain:
          "Vế if là had invested (loại 3) nên vế chính cần would not have + V3: would not have gone. Would not go là loại 2, sai mốc thời gian.",
      },
      {
        type: "fill",
        q: "You can borrow my laptop as long as you ___ it back by Friday.",
        hint: "(bring)",
        answers: ["bring"],
        explain:
          "As long as giống if của loại 1: dù nói về tương lai vẫn dùng hiện tại đơn (bring). Will bring là lỗi thường gặp vì sau từ chỉ điều kiện không dùng will.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 3. Câu bị động
  // ---------------------------------------------------------------------------
  {
    id: "passive-voice",
    group: "complex",
    band: "6.0",
    title: "Câu bị động",
    en: "The Passive Voice",
    summary:
      "Câu bị động (passive voice) đưa đối tượng chịu tác động lên làm chủ ngữ, giúp văn viết khách quan và trang trọng. Đây là cấu trúc bắt buộc khi mô tả quy trình (process) trong Writing Task 1 và rất hữu ích để nêu quan điểm chung trong Task 2.",
    rules: [
      {
        title: "Công thức bị động theo các thì",
        body:
          "Bị động luôn gồm be + V3; chỉ có be thay đổi theo thì, còn V3 giữ nguyên. Chỉ nêu by + tác nhân khi tác nhân thực sự quan trọng.",
        form: "Hiện tại đơn: am/is/are + V3 | Quá khứ đơn: was/were + V3 | Hiện tại hoàn thành: have/has been + V3 | Tiếp diễn: am/is/are/was/were being + V3",
        examples: [
          {
            en: "Over 2,000 new homes **have been built** in the area since 2015.",
            vi: "Hơn 2.000 ngôi nhà mới đã được xây trong khu vực từ năm 2015.",
          },
          {
            en: "The bridge **was completed** in 2010.",
            vi: "Cây cầu được hoàn thành vào năm 2010.",
          },
          {
            en: "A new hospital **is being constructed** in the city centre.",
            vi: "Một bệnh viện mới đang được xây dựng ở trung tâm thành phố.",
          },
        ],
      },
      {
        title: "Bị động với động từ khuyết thiếu (modal passive)",
        body:
          "Sau modal dùng be + V3 để nói điều nên/phải/có thể được làm; dùng have been + V3 để nói về quá khứ. Cấu trúc này rất tự nhiên khi đề xuất giải pháp.",
        form: "S + modal + be + V3 | S + modal + have been + V3",
        examples: [
          {
            en: "Single-use plastic bags **should be banned** in supermarkets.",
            vi: "Túi nhựa dùng một lần nên bị cấm trong các siêu thị.",
          },
          {
            en: "More money **must be invested** in renewable energy.",
            vi: "Cần phải đầu tư nhiều tiền hơn vào năng lượng tái tạo.",
          },
          {
            en: "The disaster **could have been prevented** with better planning.",
            vi: "Thảm hoạ lẽ ra đã có thể được ngăn chặn nếu có kế hoạch tốt hơn.",
          },
        ],
      },
      {
        title: "Bị động khách quan: It is believed that… / S is thought to…",
        body:
          "Dùng với say, believe, think, argue, expect, report để nêu quan điểm chung mà không nói rõ ai nghĩ vậy. Dạng thứ hai đưa chủ thể lên đầu câu, theo sau là to V (cùng thời điểm) hoặc to have V3 (xảy ra trước).",
        form: "It + is + said/believed/argued + that + mệnh đề | S + is + said/believed/thought + to V / to have V3",
        examples: [
          {
            en: "**It is widely believed that** technology has made people less sociable.",
            vi: "Nhiều người cho rằng công nghệ khiến con người ít giao tiếp hơn.",
          },
          {
            en: "Air pollution **is thought to cause** millions of premature deaths each year.",
            vi: "Ô nhiễm không khí được cho là gây ra hàng triệu ca tử vong sớm mỗi năm.",
          },
          {
            en: "The fire **is believed to have started** in the kitchen.",
            vi: "Đám cháy được cho là đã bắt đầu từ nhà bếp.",
          },
        ],
      },
      {
        title: "Khi nào nên dùng bị động",
        body:
          "Dùng khi không biết, không cần hoặc không muốn nêu người thực hiện, đặc biệt trong mô tả quy trình và văn học thuật. Quy trình sản xuất gần như luôn viết ở bị động hiện tại đơn kèm từ chỉ trình tự.",
        form: "First/Next/After that/Finally, + S + is/are + V3",
        examples: [
          {
            en: "First, the cocoa beans **are harvested** and then they **are left** to dry in the sun.",
            vi: "Đầu tiên, hạt ca cao được thu hoạch rồi đem phơi khô dưới nắng.",
          },
          {
            en: "After that, the glass **is melted** and **poured** into moulds.",
            vi: "Sau đó, thuỷ tinh được nấu chảy rồi rót vào khuôn.",
          },
          {
            en: "Finally, the bottles **are transported** to supermarkets.",
            vi: "Cuối cùng, các chai được vận chuyển tới siêu thị.",
          },
        ],
      },
      {
        title: "Nội động từ không có bị động; tránh get-passive khi viết",
        body:
          "Các nội động từ (intransitive verbs) như happen, occur, rise, fall, increase, appear, die, arrive không có tân ngữ nên không có dạng bị động. Dạng get + V3 (get-passive) chỉ dùng khi nói; trong Writing hãy dùng be + V3.",
        examples: [
          {
            en: "The accident **happened** at midnight.",
            vi: "Vụ tai nạn xảy ra lúc nửa đêm.",
          },
          {
            en: "The number of international tourists **rose** sharply after 2015.",
            vi: "Số khách du lịch quốc tế tăng mạnh sau năm 2015.",
          },
          {
            en: "Thousands of workers **were dismissed** during the recession.",
            vi: "Hàng nghìn công nhân bị cho nghỉ việc trong thời kỳ suy thoái (thay cho \"got fired\" khi viết).",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip:
          "Bài quy trình (process diagram) nên viết chủ yếu bằng bị động hiện tại đơn, xen thêm bị động hoàn thành sau once/after để nối các bước. Chia đúng be và V3 xuyên suốt bài là yếu tố chính về độ chính xác ngữ pháp ở dạng bài này.",
        example:
          "Once the grapes have been picked, they are crushed to extract the juice, which is then stored in large tanks.",
      },
      {
        part: "Writing Task 2",
        tip:
          "Mở đoạn bằng It is often argued that… hoặc X is widely believed to… để giới thiệu quan điểm của người khác một cách khách quan. Cấu trúc này vừa học thuật vừa đa dạng, nhưng chỉ dùng một hai lần để tránh rập khuôn.",
        example:
          "It is often argued that zoos are cruel to animals; however, many of them play a vital role in protecting endangered species.",
      },
      {
        part: "Speaking",
        tip:
          "Bị động xuất hiện tự nhiên khi giới thiệu quê hương, công trình hay đồ vật (be known for, was built in…). Đừng ép mọi câu thành bị động; dùng đúng ở vài chỗ phù hợp đã đủ thể hiện độ đa dạng.",
        example: "My hometown is known for its seafood, and the old bridge there was built in the 19th century.",
      },
    ],
    mistakes: [
      {
        wrong: "The accident was happened yesterday.",
        right: "The accident happened yesterday.",
        note: "Happen là nội động từ nên không có dạng bị động.",
      },
      {
        wrong: "Many trees have cut down to build the new road.",
        right: "Many trees have been cut down to build the new road.",
        note: "Thiếu been nên câu thành chủ động, nghĩa là cây tự chặt.",
      },
      {
        wrong: "The new law was introduce in 2019.",
        right: "The new law was introduced in 2019.",
        note: "Sau be trong câu bị động phải là V3, không dùng động từ nguyên mẫu.",
      },
      {
        wrong: "Vietnamese is speaking by about 100 million people.",
        right: "Vietnamese is spoken by about 100 million people.",
        note: "Bị động dùng V3 (spoken); be + V-ing là thì tiếp diễn chủ động.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Over 500 new schools ___ in rural areas since 2015.",
        options: ["have built", "have been built", "were built", "are built"],
        answer: 1,
        explain:
          "Since 2015 đòi hỏi hiện tại hoàn thành, và trường học được xây nên phải là bị động: have been built. Have built thiếu been; were built không đi với since.",
      },
      {
        type: "choice",
        q: "In the next stage, the raw materials ___ to a very high temperature.",
        options: ["heat", "are heating", "are heated", "heated"],
        answer: 2,
        explain:
          "Mô tả quy trình dùng bị động hiện tại đơn: are heated. Are heating là chủ động tiếp diễn (nguyên liệu tự đun); heated một mình thiếu be.",
      },
      {
        type: "choice",
        q: "The number of unemployed people ___ dramatically in 2009.",
        options: ["rose", "was risen", "has been risen", "was rised"],
        answer: 0,
        explain:
          "Rise là nội động từ, không có bị động, và năm 2009 là mốc quá khứ nên dùng quá khứ đơn rose. Was risen là lỗi rất hay gặp; rised không tồn tại.",
      },
      {
        type: "choice",
        q: "___ that the new policy will reduce poverty in rural areas.",
        options: ["It expects", "It is expecting", "It was expect", "It is expected"],
        answer: 3,
        explain:
          "Cấu trúc bị động khách quan là It is + V3 + that: It is expected that… It expects/It is expecting là chủ động, vô nghĩa vì it không phải người mong đợi.",
      },
      {
        type: "choice",
        q: "The flood damage ___ if the dams had been properly maintained.",
        options: ["could be prevented", "could have prevented", "could have been prevented", "could prevent"],
        answer: 2,
        explain:
          "Thiệt hại \"lẽ ra đã có thể được ngăn chặn\" trong quá khứ: modal + have been + V3. Could have prevented là chủ động, thiếu been.",
      },
      {
        type: "choice",
        q: "Chọn câu phù hợp nhất cho văn viết học thuật (Writing Task 2):",
        options: [
          "A lot of trees got cut down to build new roads.",
          "A large number of trees were cut down to build new roads.",
          "They cut down loads of trees to build new roads, you know.",
          "Many trees was cut down to build new roads.",
        ],
        answer: 1,
        explain:
          "Câu đúng dùng bị động be + V3 và từ vựng trang trọng. Got cut down là get-passive mang tính văn nói; câu có you know quá suồng sã; was không hoà hợp với chủ ngữ số nhiều trees.",
      },
      {
        type: "fill",
        q: "Smartphones ___ by millions of children every day.",
        hint: "(use)",
        answers: ["are used"],
        explain:
          "Every day chỉ thói quen nên dùng hiện tại đơn, và điện thoại được sử dụng nên là bị động: are used. Are using là chủ động, nghĩa sai.",
      },
      {
        type: "fill",
        q: "A new metro line ___ at the moment, so traffic in the city centre is heavy.",
        hint: "(build)",
        answers: ["is being built"],
        explain:
          "At the moment đòi hỏi hiện tại tiếp diễn; bị động tiếp diễn là is being + V3: is being built. Is built bỏ mất nghĩa \"đang\".",
      },
      {
        type: "fill",
        q: "Excessive sugar consumption is thought ___ a major cause of obesity.",
        hint: "(be)",
        answers: ["to be"],
        explain:
          "Sau S + is thought dùng to V khi hai sự việc cùng thời điểm: is thought to be. Being hay be không theo cấu trúc này.",
      },
      {
        type: "fill",
        q: "All applications must ___ before 30 June.",
        hint: "(submit)",
        answers: ["be submitted"],
        explain:
          "Đơn được nộp nên dùng bị động sau modal: must be submitted. Must submit là chủ động, nghĩa sai (đơn không tự nộp).",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 4. Danh động từ & động từ nguyên mẫu
  // ---------------------------------------------------------------------------
  {
    id: "gerunds-infinitives",
    group: "complex",
    band: "6.0",
    title: "Danh động từ & động từ nguyên mẫu",
    en: "Gerunds and Infinitives",
    summary:
      "Bài này giúp bạn chọn đúng giữa danh động từ (gerund, V-ing) và động từ nguyên mẫu có to (to-infinitive) sau động từ, giới từ và tính từ. Đây là nhóm lỗi nhỏ nhưng xuất hiện dày đặc, ảnh hưởng trực tiếp tới độ chính xác trong cả Writing và Speaking.",
    rules: [
      {
        title: "Động từ + V-ing và động từ + to V",
        body:
          "Một số động từ luôn đi với V-ing, số khác luôn đi với to V; cách chắc chắn nhất là học thuộc theo nhóm. Riêng suggest/recommend không dùng cấu trúc tân ngữ + to V.",
        form: "enjoy/avoid/consider/suggest/admit/deny/risk/finish + V-ing | want/decide/plan/hope/agree/refuse/afford/manage/fail + to V",
        examples: [
          {
            en: "Many people **avoid using** public transport because it is unreliable.",
            vi: "Nhiều người tránh đi phương tiện công cộng vì nó không đáng tin cậy.",
          },
          {
            en: "The government **has decided to raise** the minimum wage.",
            vi: "Chính phủ đã quyết định tăng lương tối thiểu.",
          },
          {
            en: "Experts **suggest reducing** screen time for young children.",
            vi: "Các chuyên gia khuyên nên giảm thời gian dùng thiết bị điện tử cho trẻ nhỏ.",
          },
        ],
      },
      {
        title: "Giới từ + V-ing; V-ing làm chủ ngữ",
        body:
          "Sau mọi giới từ (in, of, about, for, by, without, before, after…) động từ phải ở dạng V-ing; chú ý to cũng là giới từ trong look forward to, be used to, contribute to, the key to. V-ing làm chủ ngữ được coi là số ít.",
        form: "giới từ + V-ing | V-ing + V (số ít)",
        examples: [
          {
            en: "Many students are interested **in studying** abroad.",
            vi: "Nhiều sinh viên quan tâm đến việc du học.",
          },
          {
            en: "You can improve your English **by reading** newspapers every day.",
            vi: "Bạn có thể cải thiện tiếng Anh bằng cách đọc báo mỗi ngày.",
          },
          {
            en: "**Exercising** regularly **reduces** the risk of heart disease.",
            vi: "Tập thể dục đều đặn làm giảm nguy cơ mắc bệnh tim.",
          },
        ],
      },
      {
        title: "Động từ đổi nghĩa: stop, remember, forget, try",
        body:
          "Remember/forget + V-ing nói về việc đã làm trong quá khứ; + to V nói về việc cần làm. Stop + V-ing là bỏ hẳn việc đó, stop + to V là dừng lại để làm việc khác; try + V-ing là thử làm, try + to V là cố gắng làm.",
        form: "stop/remember/forget + V-ing (việc đã/đang làm) | + to V (việc sắp/cần làm) | try + V-ing (thử) / try + to V (cố gắng)",
        examples: [
          {
            en: "He **stopped smoking** after his heart attack.",
            vi: "Anh ấy bỏ thuốc lá sau cơn đau tim.",
          },
          {
            en: "Please **remember to submit** your assignment before Friday.",
            vi: "Nhớ nộp bài tập trước thứ Sáu nhé.",
          },
          {
            en: "If the app keeps crashing, **try reinstalling** it.",
            vi: "Nếu ứng dụng cứ bị treo, hãy thử cài đặt lại.",
          },
        ],
      },
      {
        title: "Used to + V và be/get used to + V-ing",
        body:
          "Used to + V nói về thói quen hoặc trạng thái trong quá khứ nay không còn. Be used to + V-ing là đã quen với việc gì, get used to + V-ing là dần quen; ở đây to là giới từ nên theo sau là V-ing.",
        form: "used to + V | be/get used to + V-ing/N",
        examples: [
          {
            en: "People **used to write** letters, but now they mostly send emails.",
            vi: "Trước đây người ta hay viết thư, còn giờ chủ yếu gửi email.",
          },
          {
            en: "International students soon **get used to living** in a new culture.",
            vi: "Sinh viên quốc tế sớm quen với cuộc sống trong một nền văn hoá mới.",
          },
          {
            en: "I **am used to working** late at night.",
            vi: "Tôi đã quen làm việc khuya.",
          },
        ],
      },
      {
        title: "Tính từ + to V; too/enough + to V",
        body:
          "Sau nhiều tính từ (difficult, important, essential, reluctant, likely…) dùng to V. Cấu trúc It is + adj + for sb + to V rất phổ biến trong văn viết học thuật.",
        form: "It is + adj + (for sb) + to V | S + be + adj + to V | too + adj + to V",
        examples: [
          {
            en: "**It is difficult for** elderly people **to adapt** to new technology.",
            vi: "Người cao tuổi khó thích nghi với công nghệ mới.",
          },
          {
            en: "Young people are often **reluctant to save** money.",
            vi: "Người trẻ thường ngại tiết kiệm tiền.",
          },
          {
            en: "For many young workers, the capital is **too expensive to live in**.",
            vi: "Với nhiều người lao động trẻ, thủ đô quá đắt đỏ để sinh sống.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip:
          "Mở câu bằng V-ing làm chủ ngữ hoặc dùng It is essential/vital for… to V để nêu giải pháp thay cho câu bắt đầu bằng We should. Cách này đa dạng hoá cấu trúc câu, nhưng nhớ chia động từ chính ở số ít.",
        example:
          "Investing in public transport is the most effective way to reduce traffic congestion in large cities.",
      },
      {
        part: "Writing",
        tip:
          "Cẩn thận với to là giới từ: contribute to, lead to, the key to, be committed to đều đi với V-ing. Đây là lỗi giám khảo hay bắt gặp ở band 5–6; viết đúng giúp giảm lỗi lặp lại trong tiêu chí Accuracy.",
        example: "Stricter regulations would contribute to reducing plastic waste in the oceans.",
      },
      {
        part: "Speaking",
        tip:
          "Khi được hỏi về thay đổi trong cuộc sống (Part 1, Part 3), dùng used to + V cho quá khứ và be used to + V-ing cho hiện tại để so sánh. Hai cấu trúc trông giống nhau nhưng dùng đúng cho thấy bạn kiểm soát ngữ pháp tốt.",
        example:
          "I used to play football every afternoon, but now I'm used to spending most of my day at a desk.",
      },
    ],
    mistakes: [
      {
        wrong: "Many people avoid to use public transport.",
        right: "Many people avoid using public transport.",
        note: "Avoid luôn đi với V-ing.",
      },
      {
        wrong: "I look forward to hear from you.",
        right: "I look forward to hearing from you.",
        note: "To trong look forward to là giới từ nên theo sau phải là V-ing.",
      },
      {
        wrong: "I am used to get up early.",
        right: "I am used to getting up early.",
        note: "Be used to (đã quen với) đi với V-ing; used to + V chỉ thói quen trong quá khứ.",
      },
      {
        wrong: "The teacher suggested us to read more books.",
        right: "The teacher suggested reading more books. / The teacher suggested that we read more books.",
        note: "Suggest không dùng cấu trúc suggest sb to V.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Many young people cannot afford ___ a house in big cities.",
        options: ["buying", "to buy", "buy", "to buying"],
        answer: 1,
        explain:
          "Afford đi với to V: afford to buy. Buying sai vì afford không đi với V-ing; to buying sai vì to ở đây không phải giới từ.",
      },
      {
        type: "choice",
        q: "The company is considering ___ a four-day working week.",
        options: ["introducing", "to introduce", "introduce", "to introducing"],
        answer: 0,
        explain:
          "Consider luôn đi với V-ing: considering introducing. To introduce là lỗi phổ biến do dịch từ \"cân nhắc để…\".",
      },
      {
        type: "choice",
        q: "I'll never forget ___ the Great Wall for the first time.",
        options: ["to see", "see", "seen", "seeing"],
        answer: 3,
        explain:
          "Ý là không quên một trải nghiệm đã xảy ra, nên dùng forget + V-ing: seeing. Forget to see nghĩa là quên không đi xem, trái nghĩa.",
      },
      {
        type: "choice",
        q: "After moving to London, she quickly got used to ___ on the left.",
        options: ["drive", "driving", "drove", "have driven"],
        answer: 1,
        explain:
          "Get used to (dần quen với) có to là giới từ, nên theo sau là V-ing: driving. Drive sai vì nhầm với used to + V (thói quen quá khứ).",
      },
      {
        type: "choice",
        q: "___ a second language at an early age has many cognitive benefits.",
        options: ["Learn", "To learning", "Learning", "Learned"],
        answer: 2,
        explain:
          "Chủ ngữ là một hành động nên dùng danh động từ Learning, đi với động từ số ít has. Learn là động từ nguyên thể, không làm chủ ngữ được; to learning sai dạng.",
      },
      {
        type: "choice",
        q: "The doctor told him to stop ___ because it was damaging his lungs.",
        options: ["to smoke", "smoke", "smoked", "smoking"],
        answer: 3,
        explain:
          "Bỏ hẳn một thói quen là stop + V-ing: stop smoking. Stop to smoke nghĩa là dừng việc khác lại để hút thuốc, trái với lời khuyên của bác sĩ.",
      },
      {
        type: "fill",
        q: "Many office workers are worried about ___ their jobs to automation.",
        hint: "(lose)",
        answers: ["losing"],
        explain:
          "Sau giới từ about phải dùng V-ing: losing. To lose sai vì không có giới từ nào đi với to V.",
      },
      {
        type: "fill",
        q: "Please remember ___ your passport before you leave for the airport.",
        hint: "(bring)",
        answers: ["to bring"],
        explain:
          "Đây là việc cần làm trong tương lai nên dùng remember + to V: to bring. Remember bringing nghĩa là nhớ đã mang theo, sai ngữ cảnh.",
      },
      {
        type: "fill",
        q: "When I was a child, I used ___ to school by bike every day.",
        hint: "(go)",
        answers: ["to go"],
        explain:
          "Thói quen trong quá khứ nay không còn: used to + V nguyên mẫu (to go). To going sai vì đó là cấu trúc be used to + V-ing.",
      },
      {
        type: "fill",
        q: "It is important for students ___ critical thinking skills.",
        hint: "(develop)",
        answers: ["to develop"],
        explain:
          "Cấu trúc It is + adj + for sb + to V: to develop. Developing không dùng được sau for sb trong mẫu câu này.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 5. Động từ khuyết thiếu
  // ---------------------------------------------------------------------------
  {
    id: "modal-verbs",
    group: "complex",
    band: "6.0",
    title: "Động từ khuyết thiếu",
    en: "Modal Verbs",
    summary:
      "Động từ khuyết thiếu (modal verbs) diễn đạt khả năng, sự bắt buộc, lời khuyên, phỏng đoán và hối tiếc. Trong IELTS, chúng giúp bạn đưa ra khuyến nghị ở Task 2 và nói giảm nhẹ (hedging) để lập luận thận trọng, học thuật hơn.",
    rules: [
      {
        title: "Khả năng: can, could, be able to",
        body:
          "Can/could chỉ năng lực chung ở hiện tại/quá khứ. Khi nói về một lần làm được việc khó trong quá khứ, dùng was/were able to (hoặc managed to) chứ không dùng could ở thể khẳng định; với các thì khác dùng be able to.",
        form: "can/could + V | will be able to / have been able to + V | was/were able to + V (thành công cụ thể)",
        examples: [
          {
            en: "Many elderly people **cannot use** smartphones confidently.",
            vi: "Nhiều người cao tuổi không thể dùng điện thoại thông minh một cách tự tin.",
          },
          {
            en: "Thanks to the internet, students **are able to access** courses from anywhere.",
            vi: "Nhờ internet, sinh viên có thể truy cập các khoá học từ bất cứ đâu.",
          },
          {
            en: "After months of practice, she **was able to pass** the driving test.",
            vi: "Sau nhiều tháng luyện tập, cô ấy đã thi đỗ bằng lái.",
          },
        ],
      },
      {
        title: "Bắt buộc và lời khuyên: must, have to, should, ought to",
        body:
          "Must và have to chỉ sự bắt buộc; should/ought to là lời khuyên, nhẹ hơn. Chú ý mustn't là cấm, còn don't have to là không cần thiết.",
        form: "must/have to + V | should/ought to + V | mustn't + V (cấm) ≠ don't have to + V (không cần)",
        examples: [
          {
            en: "All drivers **must wear** seat belts.",
            vi: "Mọi tài xế đều phải thắt dây an toàn.",
          },
          {
            en: "Employees **have to work** overtime during busy periods.",
            vi: "Nhân viên phải làm thêm giờ vào mùa cao điểm.",
          },
          {
            en: "Students **don't have to wear** uniforms here, but they **mustn't smoke** on campus.",
            vi: "Sinh viên ở đây không cần mặc đồng phục, nhưng không được hút thuốc trong khuôn viên trường.",
          },
        ],
      },
      {
        title: "Khả năng xảy ra: may, might, could",
        body:
          "Dùng may/might/could + V để nói điều có thể xảy ra nhưng không chắc chắn; might thường thể hiện mức độ chắc chắn thấp hơn may một chút. Đây là cách nói giảm nhẹ quan trọng trong văn học thuật.",
        form: "S + may/might/could + V",
        examples: [
          {
            en: "Artificial intelligence **may replace** many office jobs in the future.",
            vi: "Trí tuệ nhân tạo có thể thay thế nhiều công việc văn phòng trong tương lai.",
          },
          {
            en: "The policy **could lead to** higher unemployment.",
            vi: "Chính sách này có thể dẫn đến tỷ lệ thất nghiệp cao hơn.",
          },
          {
            en: "House prices **might fall** slightly next year.",
            vi: "Giá nhà có thể giảm nhẹ vào năm sau.",
          },
        ],
      },
      {
        title: "Suy luận (deduction) ở hiện tại và quá khứ",
        body:
          "Must + V nghĩa là \"chắc hẳn\", can't + V là \"chắc chắn không\" dựa trên bằng chứng. Với quá khứ dùng must/can't/couldn't + have + V3; may/might/could + have + V3 khi chỉ phỏng đoán.",
        form: "must/can't + V (hiện tại) | must/can't/couldn't + have + V3 (quá khứ) | may/might/could + have + V3",
        examples: [
          {
            en: "He has been working for twelve hours, so he **must be** exhausted.",
            vi: "Anh ấy đã làm việc mười hai tiếng, chắc hẳn đang kiệt sức.",
          },
          {
            en: "The streets are wet. It **must have rained** last night.",
            vi: "Đường ướt. Chắc hẳn đêm qua trời đã mưa.",
          },
          {
            en: "She **can't have failed** the exam; she studied extremely hard.",
            vi: "Cô ấy không thể nào trượt kỳ thi được; cô ấy học cực kỳ chăm.",
          },
        ],
      },
      {
        title: "Hối tiếc và phê phán về quá khứ: should have V3",
        body:
          "Should/ought to + have + V3 nói về việc lẽ ra nên làm nhưng đã không làm; shouldn't have + V3 là việc lẽ ra không nên làm nhưng đã làm.",
        form: "should/ought to + have + V3 | shouldn't + have + V3",
        examples: [
          {
            en: "The government **should have invested** more in flood prevention.",
            vi: "Lẽ ra chính phủ nên đầu tư nhiều hơn vào phòng chống lũ.",
          },
          {
            en: "I **shouldn't have chosen** such a difficult topic for my thesis.",
            vi: "Lẽ ra tôi không nên chọn đề tài khó như vậy cho luận văn.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip:
          "Khi đưa khuyến nghị, đổi mức độ bằng nhiều modal khác nhau (must cho việc cấp thiết, should/ought to cho lời khuyên) và kết hợp với bị động (should be + V3). Sự đa dạng có kiểm soát này được tính vào Grammatical Range; đừng lặp should ở mọi câu.",
        example:
          "Governments should introduce stricter regulations on plastic packaging, and manufacturers must be held responsible for the waste they produce.",
      },
      {
        part: "Writing",
        tip:
          "Dùng may/might/could để nói giảm nhẹ khi đưa ra nhận định chưa chắc chắn tuyệt đối. Lập luận thận trọng giúp tránh khẳng định quá đà và thể hiện văn phong học thuật chính xác.",
        example: "Excessive screen time may contribute to poor sleep quality among teenagers.",
      },
      {
        part: "Speaking",
        tip:
          "Ở Part 2 và Part 3, dùng might have + V3 khi không nhớ chính xác và should have + V3 để nói về điều hối tiếc. Đây là cấu trúc modal hoàn thành mà thí sinh band 5 hiếm khi dùng đúng.",
        example:
          "I think it might have been around 2015, and looking back, I should have started learning English much earlier.",
      },
    ],
    mistakes: [
      {
        wrong: "You should to study harder.",
        right: "You should study harder.",
        note: "Sau should (và các modal khác trừ ought to) dùng V nguyên mẫu không to.",
      },
      {
        wrong: "She can speaks three languages.",
        right: "She can speak three languages.",
        note: "Động từ sau modal không chia theo ngôi, không thêm -s.",
      },
      {
        wrong: "He must went home already.",
        right: "He must have gone home already.",
        note: "Suy luận về quá khứ dùng must + have + V3, không dùng must + V2.",
      },
      {
        wrong: "It's Sunday, so you mustn't go to work.",
        right: "It's Sunday, so you don't have to go to work.",
        note: "Mustn't là cấm; ý \"không cần\" phải dùng don't have to.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Governments ___ invest more in renewable energy to combat climate change.",
        options: ["ought", "should to", "must to", "should"],
        answer: 3,
        explain:
          "Should + V nguyên mẫu: should invest. Should to và must to sai vì modal không đi với to; ought phải có to (ought to invest).",
      },
      {
        type: "choice",
        q: "Her car isn't in the car park. She ___ left the office already.",
        options: ["must have", "must", "can't have", "should have"],
        answer: 0,
        explain:
          "Dựa vào bằng chứng (xe không còn) để suy luận chắc chắn về quá khứ: must have left. Should have left là \"lẽ ra nên\", sai nghĩa; can't have trái với bằng chứng.",
      },
      {
        type: "choice",
        q: "He ___ be at home now; I've just seen him at the library.",
        options: ["must", "can't", "should", "mustn't"],
        answer: 1,
        explain:
          "Bằng chứng cho thấy điều đó chắc chắn không đúng, nên dùng can't be. Mustn't là cấm đoán, không dùng để suy luận phủ định.",
      },
      {
        type: "choice",
        q: "Entry to the museum is free, so visitors ___ buy tickets.",
        options: ["mustn't", "can't", "don't have to", "shouldn't have"],
        answer: 2,
        explain:
          "Vào cửa miễn phí nghĩa là không cần mua vé: don't have to. Mustn't nghĩa là bị cấm mua vé, sai nghĩa.",
      },
      {
        type: "choice",
        q: "Despite the heavy rain, the rescue team ___ reach the village on time.",
        options: ["could", "was able to", "can", "might"],
        answer: 1,
        explain:
          "Một lần làm được việc khó trong quá khứ dùng was able to. Could ở thể khẳng định chỉ năng lực chung, không dùng cho một thành công cụ thể như vậy.",
      },
      {
        type: "choice",
        q: "I failed the test. I ___ harder.",
        options: ["should study", "must have studied", "should have studied", "could study"],
        answer: 2,
        explain:
          "Hối tiếc về việc không làm trong quá khứ: should have studied. Must have studied là suy luận \"chắc hẳn đã học\", mâu thuẫn với việc trượt.",
      },
      {
        type: "fill",
        q: "The window is broken. Someone ___ it last night.",
        hint: "(must / break)",
        answers: ["must have broken"],
        explain:
          "Suy luận chắc chắn về quá khứ: must + have + V3 (broken). Must break hoặc must broke sai vì không thể hiện thời quá khứ đúng cách.",
      },
      {
        type: "fill",
        q: "Students ___ cheat in exams; it is strictly forbidden.",
        hint: "(must, phủ định)",
        answers: ["mustn't", "must not"],
        explain:
          "Strictly forbidden là cấm nên dùng mustn't. Don't have to sai vì chỉ có nghĩa là không cần thiết.",
      },
      {
        type: "fill",
        q: "Living costs ___ next year, so families should start saving now.",
        hint: "(may / rise)",
        answers: ["may rise"],
        explain:
          "Dự đoán chưa chắc chắn về tương lai: may + V nguyên mẫu (may rise). May rises hoặc may to rise sai vì sau modal không chia động từ và không có to.",
      },
      {
        type: "fill",
        q: "We ___ so much food for the party; half of it was thrown away.",
        hint: "(should, phủ định / buy)",
        answers: ["shouldn't have bought", "should not have bought"],
        explain:
          "Việc lẽ ra không nên làm nhưng đã làm trong quá khứ: shouldn't have + V3 (bought). Shouldn't buy chỉ là lời khuyên cho hiện tại/tương lai.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 6. Liên từ, từ nối & câu nhượng bộ
  // ---------------------------------------------------------------------------
  {
    id: "linking-concession",
    group: "complex",
    band: "6.0",
    title: "Liên từ, từ nối & câu nhượng bộ",
    en: "Linking Words and Concession",
    summary:
      "Bài này phân biệt liên từ (conjunction) đi với mệnh đề, giới từ đi với danh từ và trạng từ nối (linking adverb) cùng cách dùng dấu câu. Nối câu đúng giúp bài viết mạch lạc và tránh lỗi câu dính (run-on) hay câu cụt (fragment) vốn rất hay bị trừ điểm.",
    rules: [
      {
        title: "Nhượng bộ: although/even though + mệnh đề, despite/in spite of + danh từ",
        body:
          "Although, though, even though đi với một mệnh đề đầy đủ (S + V). Despite và in spite of là giới từ, đi với danh từ, V-ing hoặc the fact that + mệnh đề; không bao giờ có despite of.",
        form: "Although/Even though + S + V, S + V | Despite/In spite of + N/V-ing/the fact that + S + V, S + V",
        examples: [
          {
            en: "**Although** online courses are convenient, many students still prefer face-to-face classes.",
            vi: "Mặc dù các khoá học trực tuyến tiện lợi, nhiều sinh viên vẫn thích học trực tiếp hơn.",
          },
          {
            en: "**Despite** the high cost, many families send their children to private schools.",
            vi: "Bất chấp chi phí cao, nhiều gia đình vẫn cho con học trường tư.",
          },
          {
            en: "**In spite of having** a degree, he could not find a well-paid job.",
            vi: "Dù có bằng đại học, anh ấy vẫn không tìm được việc lương cao.",
          },
        ],
      },
      {
        title: "Đối lập: while và whereas",
        body:
          "While và whereas nối hai mệnh đề có ý trái ngược nhau, rất hợp để so sánh hai đối tượng. Chúng có thể đứng đầu câu hoặc giữa câu, thường có dấu phẩy ngăn cách hai vế.",
        form: "S + V, whereas/while + S + V | While + S + V, S + V",
        examples: [
          {
            en: "Rural incomes rose slowly, **whereas** urban incomes doubled.",
            vi: "Thu nhập ở nông thôn tăng chậm, trong khi thu nhập ở thành thị tăng gấp đôi.",
          },
          {
            en: "**While** some people believe homework is essential, others think it is a waste of time.",
            vi: "Trong khi một số người tin rằng bài tập về nhà là cần thiết, những người khác cho rằng nó lãng phí thời gian.",
          },
        ],
      },
      {
        title: "Trạng từ nối: however, nevertheless, therefore, moreover",
        body:
          "Đây là trạng từ, không phải liên từ, nên không nối hai mệnh đề bằng dấu phẩy. Dùng dấu chấm hoặc dấu chấm phẩy trước, và dấu phẩy ngay sau từ nối.",
        form: "Mệnh đề 1. However, mệnh đề 2. | Mệnh đề 1; however, mệnh đề 2.",
        examples: [
          {
            en: "Electric cars produce no exhaust fumes. **However,** they are still expensive.",
            vi: "Xe điện không thải khí. Tuy nhiên, chúng vẫn còn đắt.",
          },
          {
            en: "The city's population has grown rapidly**; therefore,** more affordable housing is needed.",
            vi: "Dân số thành phố tăng nhanh; vì vậy, cần thêm nhà ở giá phải chăng.",
          },
          {
            en: "The project was underfunded. **Nevertheless,** it was completed on time.",
            vi: "Dự án bị thiếu kinh phí. Dù vậy, nó vẫn hoàn thành đúng hạn.",
          },
        ],
      },
      {
        title: "Because và because of; so…that và such…that",
        body:
          "Because đi với mệnh đề, because of/due to đi với danh từ. So đi với tính từ/trạng từ, such đi với cụm danh từ (thêm a/an nếu là danh từ đếm được số ít).",
        form: "because + S + V | because of/due to + N | so + adj/adv + that | such + (a/an) + adj + N + that",
        examples: [
          {
            en: "Many people drive to work **because** public transport is unreliable.",
            vi: "Nhiều người lái xe đi làm vì giao thông công cộng không đáng tin cậy.",
          },
          {
            en: "Hundreds of flights were cancelled **because of** the storm.",
            vi: "Hàng trăm chuyến bay bị huỷ vì cơn bão.",
          },
          {
            en: "It was **such a difficult exam that** many students failed.",
            vi: "Đó là một bài thi khó đến mức nhiều học sinh trượt.",
          },
        ],
      },
      {
        title: "Tránh câu cụt (fragment) và câu dính (run-on)",
        body:
          "Mệnh đề phụ bắt đầu bằng because, although, when, which… không thể đứng một mình thành câu. Hai mệnh đề độc lập không được nối chỉ bằng dấu phẩy (comma splice); hãy dùng liên từ, dấu chấm phẩy hoặc tách thành hai câu.",
        examples: [
          {
            en: "Many people shop online **because it is cheap**.",
            vi: "Nhiều người mua sắm trực tuyến vì nó rẻ (không viết \"Because it is cheap.\" thành một câu riêng).",
          },
          {
            en: "Technology has many benefits**; however,** it also has drawbacks.",
            vi: "Công nghệ có nhiều lợi ích; tuy nhiên, nó cũng có mặt trái (không viết \"…benefits, however, it…\").",
          },
          {
            en: "Prices have risen sharply**, so** many families are struggling.",
            vi: "Giá cả tăng mạnh, nên nhiều gia đình đang chật vật.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip:
          "Dùng câu nhượng bộ với although/while để thừa nhận quan điểm đối lập trước khi phản bác, giúp lập luận cân bằng. Một câu phức có mệnh đề nhượng bộ đúng dấu câu là ví dụ rõ ràng của độ đa dạng ngữ pháp.",
        example:
          "Although tourism creates jobs for local people, it can also damage traditional cultures and the natural environment.",
      },
      {
        part: "Writing Task 1",
        tip:
          "So sánh hai đối tượng trong cùng một câu bằng whereas/while thay vì hai câu đơn. Cách này vừa thể hiện câu phức vừa làm rõ sự tương phản giữa các số liệu.",
        example:
          "The percentage of men in full-time employment fell slightly, whereas that of women rose steadily over the period.",
      },
      {
        part: "Writing",
        tip:
          "Giám khảo trừ điểm Accuracy khi gặp lỗi dấu câu như \", however,\" nối hai mệnh đề hoặc câu cụt bắt đầu bằng Because. Đừng mở mọi câu bằng một từ nối; dùng ít nhưng đúng sẽ có lợi hơn cho cả Coherence lẫn Grammar.",
        example: "Public transport is cheaper and greener; however, many people still prefer to use their own cars.",
      },
    ],
    mistakes: [
      {
        wrong: "Although it was raining, but we still went out.",
        right: "Although it was raining, we still went out.",
        note: "Tiếng Việt nói \"tuy… nhưng…\", còn tiếng Anh chỉ dùng một liên từ: although hoặc but.",
      },
      {
        wrong: "Despite of the bad weather, the match went ahead.",
        right: "Despite the bad weather, the match went ahead. / In spite of the bad weather, the match went ahead.",
        note: "Despite không đi với of; chỉ in spite of mới có of.",
      },
      {
        wrong: "Despite it was expensive, she bought the laptop.",
        right: "Although it was expensive, she bought the laptop. / Despite the high price, she bought the laptop.",
        note: "Despite là giới từ, không đi trực tiếp với mệnh đề S + V.",
      },
      {
        wrong: "Many people buy this phone. Because it is cheap.",
        right: "Many people buy this phone because it is cheap.",
        note: "Mệnh đề because không thể đứng riêng thành một câu.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "___ the government's efforts, unemployment remains high.",
        options: ["Although", "Despite", "Even though", "However"],
        answer: 1,
        explain:
          "Sau chỗ trống là cụm danh từ (the government's efforts), nên dùng giới từ Despite. Although/even though cần một mệnh đề có động từ; however là trạng từ, không đi với danh từ.",
      },
      {
        type: "choice",
        q: "___ the city has many parks, its air quality is still poor.",
        options: ["Despite", "In spite of", "Although", "Because of"],
        answer: 2,
        explain:
          "Sau chỗ trống là mệnh đề đầy đủ (the city has…) mang nghĩa nhượng bộ, nên dùng Although. Despite/in spite of chỉ đi với danh từ hoặc V-ing.",
      },
      {
        type: "choice",
        q: "Online shopping is convenient. ___, it may encourage impulsive spending.",
        options: ["However", "Although", "Despite", "Because"],
        answer: 0,
        explain:
          "Đứng đầu câu mới, trước dấu phẩy, nối ý đối lập với câu trước là trạng từ However. Although/because là liên từ, sẽ tạo câu cụt; despite cần danh từ theo sau.",
      },
      {
        type: "choice",
        q: "Many flights were delayed ___ the heavy fog.",
        options: ["because", "so", "although", "because of"],
        answer: 3,
        explain:
          "The heavy fog là cụm danh từ nên dùng because of. Because đi với mệnh đề có động từ, ví dụ because the fog was heavy.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng ngữ pháp và dấu câu:",
        options: [
          "Smartphones are useful, however, they can be addictive.",
          "Smartphones are useful; however, they can be addictive.",
          "Although smartphones are useful, but they can be addictive.",
          "Smartphones are useful. Although they can be addictive.",
        ],
        answer: 1,
        explain:
          "However nối hai mệnh đề độc lập cần dấu chấm phẩy trước và dấu phẩy sau. Phương án đầu là câu dính (comma splice); phương án dùng although… but thừa liên từ; phương án cuối có câu cụt bắt đầu bằng Although.",
      },
      {
        type: "choice",
        q: "It was ___ that many people had to stay indoors all day.",
        options: ["so hot weather", "such a hot weather", "so a hot weather", "such hot weather"],
        answer: 3,
        explain:
          "Weather là danh từ không đếm được, nên dùng such + adj + N, không có a: such hot weather. So chỉ đi với tính từ đứng một mình (so hot that…).",
      },
      {
        type: "fill",
        q: "In spite of ___ hard, he failed the final exam.",
        hint: "(study)",
        answers: ["studying", "having studied"],
        explain:
          "In spite of là giới từ nên theo sau là V-ing: studying (hoặc having studied để nhấn mạnh việc xảy ra trước). Studied hay to study đều sai sau giới từ.",
      },
      {
        type: "fill",
        q: "The project was delayed. ___, it was completed within budget.",
        hint: "(tuy vậy – trạng từ nối)",
        answers: ["However", "Nevertheless", "Nonetheless", "Even so"],
        explain:
          "Đầu câu mới, theo sau là dấu phẩy và ý đối lập, nên cần trạng từ nối như However/Nevertheless. Although không dùng được vì là liên từ, cần nối với một mệnh đề khác trong cùng câu.",
      },
      {
        type: "fill",
        q: "The new road was ___ expensive that the project was cancelled.",
        hint: "(so / such)",
        answers: ["so"],
        explain:
          "Sau chỗ trống là tính từ đứng một mình (expensive), nên dùng so…that. Such chỉ đi với cụm danh từ, ví dụ such an expensive road.",
      },
      {
        type: "fill",
        q: "Women's wages increased by 20%, ___ men's wages remained stable.",
        hint: "(liên từ chỉ đối lập, bắt đầu bằng w)",
        answers: ["whereas", "while"],
        explain:
          "Hai mệnh đề đối lập nhau trong cùng một câu, nối bằng whereas hoặc while. However không dùng được vì là trạng từ, không thể nối hai mệnh đề chỉ bằng dấu phẩy.",
      },
    ],
  },
];
