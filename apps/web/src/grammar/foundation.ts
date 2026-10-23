import type { GrammarUnit } from "./types";

export const foundation: GrammarUnit[] = [
  // 1. Thì hiện tại đơn & tiếp diễn
  {
    id: "present-tenses",
    group: "foundation",
    band: "5.0",
    title: "Thì hiện tại đơn & hiện tại tiếp diễn",
    en: "Present Simple & Present Continuous",
    summary:
      "Phân biệt hiện tại đơn (present simple) cho sự thật, thói quen với hiện tại tiếp diễn (present continuous) cho việc đang diễn ra và xu hướng hiện nay. Đây là nền tảng cho Speaking Part 1 và phần mô tả xu hướng trong Writing.",
    rules: [
      {
        title: "Hiện tại đơn: sự thật, thói quen, lịch cố định",
        body: "Dùng hiện tại đơn (present simple) cho sự thật chung, thói quen lặp lại và trạng thái lâu dài. Với chủ ngữ ngôi thứ ba số ít (he, she, it, danh từ số ít), động từ phải thêm -s/-es.",
        form: "S + V(s/es) | S + do/does + not + V",
        examples: [
          {
            en: "Most students **spend** several hours online every day.",
            vi: "Phần lớn sinh viên dành vài giờ trên mạng mỗi ngày.",
          },
          {
            en: "Public transport **reduces** traffic congestion in large cities.",
            vi: "Giao thông công cộng giúp giảm ùn tắc ở các thành phố lớn.",
          },
          {
            en: "My father **doesn't work** at weekends.",
            vi: "Bố tôi không làm việc vào cuối tuần.",
          },
        ],
      },
      {
        title: "Hiện tại tiếp diễn: việc đang diễn ra, tạm thời",
        body: "Dùng hiện tại tiếp diễn (present continuous) cho hành động đang xảy ra lúc nói hoặc tình huống tạm thời trong giai đoạn hiện nay.",
        form: "S + am/is/are + V-ing",
        examples: [
          {
            en: "I **am studying** for my IELTS exam at the moment.",
            vi: "Hiện giờ tôi đang ôn thi IELTS.",
          },
          {
            en: "My sister **is living** with our grandparents this year.",
            vi: "Năm nay em gái tôi đang sống với ông bà.",
          },
        ],
      },
      {
        title: "Hiện tại tiếp diễn cho xu hướng đang thay đổi",
        body: "Khi nói về một xu hướng (trend) đang diễn ra, dùng hiện tại tiếp diễn với các động từ chỉ sự thay đổi như increase, rise, grow, become, change.",
        form: "S + is/are + increasing/growing/becoming...",
        examples: [
          {
            en: "The cost of living **is rising** in most major cities.",
            vi: "Chi phí sinh hoạt đang tăng ở hầu hết các thành phố lớn.",
          },
          {
            en: "Online learning **is becoming** increasingly popular.",
            vi: "Học trực tuyến ngày càng trở nên phổ biến.",
          },
        ],
      },
      {
        title: "Động từ trạng thái (stative verbs)",
        body: "Các động từ chỉ trạng thái, cảm xúc, sở hữu, nhận thức (know, believe, understand, want, need, prefer, own, belong, seem, mean) thường không dùng ở dạng tiếp diễn, kể cả khi nói về lúc này.",
        examples: [
          {
            en: "Many people **believe** that technology makes life easier.",
            vi: "Nhiều người tin rằng công nghệ giúp cuộc sống dễ dàng hơn.",
          },
          {
            en: "I **don't understand** why the government has not acted.",
            vi: "Tôi không hiểu vì sao chính phủ chưa hành động.",
          },
          {
            en: "This laptop **belongs** to my company.",
            vi: "Chiếc máy tính xách tay này thuộc về công ty tôi.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Speaking",
        tip: "Ở Part 1, câu hỏi về thói quen (Do you...? How often...?) nên trả lời bằng hiện tại đơn kèm trạng từ tần suất (usually, often, rarely), rồi thêm một câu hiện tại tiếp diễn về giai đoạn hiện nay để thể hiện sự đa dạng ngữ pháp.",
        example:
          "I usually read the news on my phone, but these days I'm trying to spend less time on social media.",
      },
      {
        part: "Writing Task 2",
        tip: "Câu mở bài mô tả bối cảnh hiện nay rất hợp với hiện tại tiếp diễn chỉ xu hướng; còn câu nêu sự thật, lập luận chung thì dùng hiện tại đơn.",
        example:
          "An increasing number of young people are moving to big cities, which puts pressure on housing and transport.",
      },
      {
        part: "Writing Task 1",
        tip: "Câu giới thiệu biểu đồ dùng hiện tại đơn: The chart shows/illustrates/compares... Không viết \"The chart is showing\".",
        example:
          "The bar chart compares the amount of time spent on three leisure activities in 2020.",
      },
    ],
    mistakes: [
      {
        wrong: "My mother work in a hospital.",
        right: "My mother works in a hospital.",
        note: "Chủ ngữ ngôi thứ ba số ít phải thêm -s vào động từ; tiếng Việt không chia động từ nên rất dễ quên.",
      },
      {
        wrong: "I am knowing a lot about this topic.",
        right: "I know a lot about this topic.",
        note: "Know là động từ trạng thái, không dùng ở dạng tiếp diễn.",
      },
      {
        wrong: "The graph is showing the number of tourists.",
        right: "The graph shows the number of tourists.",
        note: "Mô tả nội dung biểu đồ là sự thật cố định nên dùng hiện tại đơn.",
      },
      {
        wrong: "Does she likes studying abroad?",
        right: "Does she like studying abroad?",
        note: "Sau trợ động từ does, động từ chính trở về nguyên mẫu, không thêm -s.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Water ___ at 100 degrees Celsius.",
        options: ["is boiling", "boils", "boil", "has boiled"],
        answer: 1,
        explain:
          "Đây là sự thật khoa học nên dùng hiện tại đơn, chủ ngữ water số ít nên là boils. \"Is boiling\" chỉ đúng khi nói nước đang sôi ngay lúc này.",
      },
      {
        type: "choice",
        q: "Look! The price of fuel ___ again this month.",
        options: ["goes up", "go up", "is going up", "went up"],
        answer: 2,
        explain:
          "\"Look!\" và \"this month\" cho thấy sự việc đang diễn ra trong giai đoạn hiện nay, nên dùng hiện tại tiếp diễn. \"Goes up\" diễn tả thói quen, không hợp ngữ cảnh.",
      },
      {
        type: "choice",
        q: "Many experts ___ that remote work improves productivity.",
        options: ["are believing", "believes", "believing", "believe"],
        answer: 3,
        explain:
          "Believe là động từ trạng thái nên không dùng tiếp diễn; chủ ngữ experts số nhiều nên không thêm -s.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng.",
        options: [
          "She don't use public transport.",
          "She doesn't use public transport.",
          "She doesn't uses public transport.",
          "She not uses public transport.",
        ],
        answer: 1,
        explain:
          "Phủ định hiện tại đơn với ngôi thứ ba số ít: doesn't + động từ nguyên mẫu. \"Doesn't uses\" sai vì đã có does thì động từ không thêm -s.",
      },
      {
        type: "choice",
        q: "The number of electric cars on the road ___ rapidly these days.",
        options: ["is growing", "grow", "are growing", "grows up"],
        answer: 0,
        explain:
          "\"These days\" chỉ xu hướng đang diễn ra nên dùng hiện tại tiếp diễn; chủ ngữ là \"the number\" (số ít) nên dùng is. \"Are growing\" sai vì chia theo cars.",
      },
      {
        type: "choice",
        q: "I ___ to the gym three times a week.",
        options: ["am going", "goes", "go", "going"],
        answer: 2,
        explain:
          "\"Three times a week\" là thói quen nên dùng hiện tại đơn; chủ ngữ I nên là go. \"Am going\" diễn tả việc đang xảy ra, không phải thói quen.",
      },
      {
        type: "fill",
        q: "This software ___ to a small start-up in Hanoi.",
        hint: "(belong)",
        answers: ["belongs"],
        explain:
          "Belong là động từ chỉ sở hữu (stative), không dùng tiếp diễn; chủ ngữ số ít nên thêm -s: belongs. \"Is belonging\" là sai.",
      },
      {
        type: "fill",
        q: "At the moment, the city council ___ a new metro line.",
        hint: "(build)",
        answers: ["is building", "'s building"],
        explain:
          "\"At the moment\" chỉ việc đang diễn ra nên dùng hiện tại tiếp diễn: is building. Hiện tại đơn \"builds\" không hợp vì không phải thói quen.",
      },
      {
        type: "fill",
        q: "My brother ___ coffee; he prefers green tea.",
        hint: "(not drink)",
        answers: ["doesn't drink", "does not drink"],
        explain:
          "Đây là thói quen, sở thích lâu dài nên dùng hiện tại đơn phủ định: doesn't drink. Không viết \"don't drink\" vì chủ ngữ ngôi thứ ba số ít.",
      },
      {
        type: "fill",
        q: "Because of rapid urbanisation, air pollution in many Asian cities ___ worse at the moment.",
        hint: "(get)",
        answers: ["is getting", "'s getting"],
        explain:
          "Get worse diễn tả sự thay đổi đang tiếp diễn, lại có \"at the moment\", nên dùng hiện tại tiếp diễn: is getting. Hiện tại đơn \"gets\" sai vì đây không phải thói quen hay sự thật chung.",
      },
    ],
  },

  // 2. Thì quá khứ
  {
    id: "past-tenses",
    group: "foundation",
    band: "5.0",
    title: "Các thì quá khứ",
    en: "Past Tenses",
    summary:
      "Ôn quá khứ đơn, quá khứ tiếp diễn, quá khứ hoàn thành và used to/would để kể chuyện mạch lạc. Đây là ngữ pháp bắt buộc khi kể trải nghiệm ở Speaking Part 2 và mô tả số liệu năm cũ ở Writing Task 1.",
    rules: [
      {
        title: "Quá khứ đơn (past simple)",
        body: "Dùng quá khứ đơn cho hành động đã xong tại một thời điểm xác định trong quá khứ (yesterday, in 2010, two years ago). Động từ có quy tắc thêm -ed, động từ bất quy tắc dùng cột 2 (V2).",
        form: "S + V2/V-ed | S + did not + V",
        examples: [
          {
            en: "The government **introduced** a new tax on plastic bags in 2018.",
            vi: "Chính phủ đưa ra thuế mới đối với túi ni lông vào năm 2018.",
          },
          {
            en: "Sales **fell** sharply between 2008 and 2009.",
            vi: "Doanh số giảm mạnh trong giai đoạn 2008 đến 2009.",
          },
          {
            en: "I **didn't go** to university straight after school.",
            vi: "Tôi không vào đại học ngay sau khi học xong phổ thông.",
          },
        ],
      },
      {
        title: "Quá khứ tiếp diễn (past continuous)",
        body: "Dùng quá khứ tiếp diễn cho hành động đang diễn ra tại một thời điểm trong quá khứ, thường làm bối cảnh cho một hành động ngắn (quá khứ đơn) xen vào.",
        form: "S + was/were + V-ing",
        examples: [
          {
            en: "I **was working** in a bank when I decided to change my career.",
            vi: "Tôi đang làm ở ngân hàng thì quyết định đổi nghề.",
          },
          {
            en: "While we **were travelling** around Japan, we met an old friend.",
            vi: "Trong lúc chúng tôi đang du lịch vòng quanh Nhật Bản thì gặp một người bạn cũ.",
          },
        ],
      },
      {
        title: "Quá khứ hoàn thành (past perfect)",
        body: "Dùng quá khứ hoàn thành cho hành động xảy ra trước một hành động hoặc thời điểm khác trong quá khứ, để làm rõ thứ tự.",
        form: "S + had + V3",
        examples: [
          {
            en: "By 2000, the population **had doubled**.",
            vi: "Đến năm 2000, dân số đã tăng gấp đôi.",
          },
          {
            en: "When I arrived at the station, the train **had** already **left**.",
            vi: "Khi tôi đến ga thì tàu đã rời đi rồi.",
          },
        ],
      },
      {
        title: "Used to và would cho thói quen trong quá khứ",
        body: "Used to + V diễn tả thói quen hoặc trạng thái trong quá khứ nay không còn. Would + V chỉ dùng cho hành động lặp lại, không dùng cho trạng thái (không nói \"I would live\").",
        form: "S + used to + V | S + would + V (hành động lặp lại)",
        examples: [
          {
            en: "I **used to live** in a small village near the coast.",
            vi: "Tôi từng sống ở một ngôi làng nhỏ gần biển.",
          },
          {
            en: "Every summer, my grandfather **would take** us fishing.",
            vi: "Mỗi mùa hè, ông tôi lại dẫn chúng tôi đi câu cá.",
          },
          {
            en: "People **didn't use to have** smartphones.",
            vi: "Trước đây người ta không có điện thoại thông minh.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Speaking",
        tip: "Ở Part 2, khi kể một trải nghiệm, hãy phối hợp quá khứ tiếp diễn làm bối cảnh, quá khứ đơn cho sự kiện chính và quá khứ hoàn thành cho việc xảy ra trước đó. Sự đa dạng này nâng điểm Grammatical Range.",
        example:
          "I was studying in my final year when I got the scholarship, which I had applied for months earlier.",
      },
      {
        part: "Writing Task 1",
        tip: "Biểu đồ có năm trong quá khứ thì mọi động từ mô tả số liệu đều ở quá khứ đơn. Dùng \"By + năm, ... had + V3\" để nói về mức đạt được tính đến một mốc.",
        example:
          "Car ownership rose steadily until 2005, and by 2010 it had reached its peak of 60%.",
      },
      {
        part: "Speaking",
        tip: "Câu hỏi so sánh quá khứ và hiện tại (Part 1, Part 3) rất hợp với used to. Nó cho thấy bạn kiểm soát cấu trúc mà không cần câu phức tạp.",
        example:
          "When I was a child, I used to play outside all day, but children today spend most of their time indoors.",
      },
    ],
    mistakes: [
      {
        wrong: "Yesterday I go to the library.",
        right: "Yesterday I went to the library.",
        note: "Có mốc quá khứ (yesterday) thì động từ phải chia quá khứ; tiếng Việt chỉ thêm \"hôm qua\" nên người học hay quên chia.",
      },
      {
        wrong: "I didn't went to the meeting.",
        right: "I didn't go to the meeting.",
        note: "Sau did/didn't, động từ trở về nguyên mẫu.",
      },
      {
        wrong: "I am used to play football when I was young.",
        right: "I used to play football when I was young.",
        note: "Thói quen trong quá khứ là \"used to + V\"; \"be used to + V-ing\" nghĩa là đã quen với việc gì.",
      },
      {
        wrong: "In 2015, the figure has increased to 40%.",
        right: "In 2015, the figure increased to 40%.",
        note: "Có năm cụ thể trong quá khứ thì dùng quá khứ đơn, không dùng hiện tại hoàn thành.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "I ___ my keys while I was walking to work.",
        options: ["lost", "was losing", "had lose", "lose"],
        answer: 0,
        explain:
          "Hành động ngắn xen vào hành động đang diễn ra (was walking) dùng quá khứ đơn: lost. \"Was losing\" sai vì làm mất chìa khoá là việc xảy ra trong khoảnh khắc.",
      },
      {
        type: "choice",
        q: "When the firefighters arrived, the fire ___ most of the building.",
        options: ["destroyed", "was destroying", "has destroyed", "had destroyed"],
        answer: 3,
        explain:
          "Việc cháy phá huỷ tòa nhà xảy ra trước khi lính cứu hoả đến, nên dùng quá khứ hoàn thành: had destroyed. \"Has destroyed\" là hiện tại hoàn thành, không hợp với mạch kể quá khứ.",
      },
      {
        type: "choice",
        q: "There ___ a cinema in my town, but it closed down years ago.",
        options: ["would be", "used to be", "was used to be", "is used to"],
        answer: 1,
        explain:
          "Trạng thái trong quá khứ nay không còn dùng used to. \"Would be\" sai vì would không dùng cho trạng thái, chỉ dùng cho hành động lặp lại.",
      },
      {
        type: "choice",
        q: "The unemployment rate ___ to 8% in 2012 and then started to fall.",
        options: ["has risen", "rises", "rose", "had been rising"],
        answer: 2,
        explain:
          "Có mốc thời gian xác định trong quá khứ (in 2012) nên dùng quá khứ đơn: rose. \"Has risen\" sai vì hiện tại hoàn thành không đi với năm cụ thể.",
      },
      {
        type: "choice",
        q: "What ___ at 9 p.m. last night? I called you twice.",
        options: ["did you do", "were you doing", "have you done", "had you done"],
        answer: 1,
        explain:
          "Hỏi về hành động đang diễn ra tại một thời điểm cụ thể trong quá khứ (9 p.m. last night) dùng quá khứ tiếp diễn. \"Did you do\" hỏi về việc đã làm xong, không hợp ngữ cảnh gọi điện.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng.",
        options: [
          "When I was a child, I would live near a river.",
          "When I was a child, I was used to live near a river.",
          "When I was a child, I used to live near a river.",
          "When I was a child, I use to living near a river.",
        ],
        answer: 2,
        explain:
          "Live là trạng thái nên dùng used to + V nguyên mẫu. Would không dùng cho trạng thái; \"was used to live\" và \"use to living\" sai cấu trúc.",
      },
      {
        type: "fill",
        q: "The company ___ 200 new staff last year.",
        hint: "(hire)",
        answers: ["hired"],
        explain:
          "\"Last year\" là mốc quá khứ xác định nên dùng quá khứ đơn: hired. Không dùng \"has hired\".",
      },
      {
        type: "fill",
        q: "By the time I graduated, I ___ three part-time jobs.",
        hint: "(have)",
        answers: ["had had"],
        explain:
          "\"By the time + quá khứ đơn\" thì mệnh đề chính dùng quá khứ hoàn thành: had had (had là trợ động từ, had là V3 của have). \"Had\" đơn thuần không làm rõ việc xảy ra trước.",
      },
      {
        type: "fill",
        q: "It ___ heavily when we left the office, so we took a taxi.",
        hint: "(rain)",
        answers: ["was raining"],
        explain:
          "Trời đang mưa là bối cảnh đang diễn ra khi một hành động khác xảy ra (we left), nên dùng quá khứ tiếp diễn: was raining.",
      },
      {
        type: "fill",
        q: "Online shopping ___ common twenty years ago.",
        hint: "(not be)",
        answers: ["wasn't", "was not"],
        explain:
          "\"Twenty years ago\" là mốc quá khứ, chủ ngữ số ít nên dùng wasn't. Không dùng \"isn't\" hay \"hasn't been\" vì đã có ago.",
      },
    ],
  },

  // 3. Hiện tại hoàn thành
  {
    id: "present-perfect",
    group: "foundation",
    band: "5.0",
    title: "Thì hiện tại hoàn thành",
    en: "Present Perfect Simple & Continuous",
    summary:
      "Hiện tại hoàn thành (present perfect) nối quá khứ với hiện tại: kinh nghiệm, thay đổi đến nay, hành động kéo dài tới bây giờ. Nắm vững cách phân biệt với quá khứ đơn giúp tránh lỗi phổ biến nhất ở Writing Task 2 và Speaking.",
    rules: [
      {
        title: "Hiện tại hoàn thành đơn: kết quả và kinh nghiệm",
        body: "Dùng cho kinh nghiệm trong đời (không nói thời điểm cụ thể), hoặc hành động trong quá khứ có kết quả ở hiện tại. Thường đi với ever, never, already, yet, just, recently.",
        form: "S + have/has + V3",
        examples: [
          {
            en: "I **have** never **studied** abroad, but I would love to.",
            vi: "Tôi chưa từng du học, nhưng tôi rất muốn.",
          },
          {
            en: "Technology **has changed** the way we communicate.",
            vi: "Công nghệ đã thay đổi cách chúng ta giao tiếp.",
          },
          {
            en: "The city **has** just **opened** its first metro line.",
            vi: "Thành phố vừa khai trương tuyến tàu điện ngầm đầu tiên.",
          },
        ],
      },
      {
        title: "For và since",
        body: "Hiện tại hoàn thành diễn tả trạng thái hoặc hành động bắt đầu trong quá khứ và kéo dài tới hiện tại. For + khoảng thời gian (for ten years); since + mốc thời gian (since 2015, since I was a child).",
        form: "S + have/has + V3 + for/since ...",
        examples: [
          {
            en: "She **has worked** as a nurse **for** ten years.",
            vi: "Cô ấy đã làm y tá được mười năm.",
          },
          {
            en: "Air quality **has improved since** the factory closed.",
            vi: "Chất lượng không khí đã cải thiện kể từ khi nhà máy đóng cửa.",
          },
        ],
      },
      {
        title: "Hiện tại hoàn thành tiếp diễn (present perfect continuous)",
        body: "Nhấn mạnh quá trình, độ dài của một hoạt động kéo dài đến hiện tại (có thể vẫn đang tiếp tục). Không dùng với động từ trạng thái như know, own, believe.",
        form: "S + have/has + been + V-ing",
        examples: [
          {
            en: "I **have been learning** English since I was eight.",
            vi: "Tôi học tiếng Anh từ năm tám tuổi tới giờ.",
          },
          {
            en: "Scientists **have been studying** the effects of microplastics for years.",
            vi: "Các nhà khoa học đã nghiên cứu tác động của vi nhựa trong nhiều năm.",
          },
        ],
      },
      {
        title: "Hiện tại hoàn thành và quá khứ đơn",
        body: "Có mốc thời gian đã kết thúc (yesterday, in 2010, ago, last year) thì dùng quá khứ đơn. Khoảng thời gian chưa kết thúc hoặc kéo dài đến nay (so far, over the past decade, in recent years, this year) thì dùng hiện tại hoàn thành.",
        examples: [
          {
            en: "Prices **rose** by 5% **last year**.",
            vi: "Giá đã tăng 5% vào năm ngoái.",
          },
          {
            en: "Prices **have risen** by 20% **over the past decade**.",
            vi: "Giá đã tăng 20% trong thập kỷ qua.",
          },
          {
            en: "I **visited** Da Nang **in 2019**, and I **have been** there twice **since then**.",
            vi: "Tôi đến Đà Nẵng năm 2019 và từ đó đến nay đã quay lại hai lần.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Mở bài bằng một thay đổi kéo dài đến nay với \"over the past decade/in recent years\" + hiện tại hoàn thành là cách vào đề tự nhiên và chính xác.",
        example:
          "Over the past decade, the number of people working from home has increased dramatically.",
      },
      {
        part: "Speaking",
        tip: "Câu hỏi \"How long have you...?\" phải trả lời bằng hiện tại hoàn thành (đơn hoặc tiếp diễn) + for/since, không trả lời bằng hiện tại đơn.",
        example:
          "I've been living in Ho Chi Minh City for about five years, since I started university.",
      },
      {
        part: "Writing Task 1",
        tip: "Phần lớn Task 1 dùng quá khứ đơn. Chỉ dùng hiện tại hoàn thành khi dữ liệu kéo dài đến hiện tại (ví dụ \"since 2010\" đến năm hiện tại); có năm kết thúc trong quá khứ thì giữ quá khứ đơn.",
        example:
          "Between 2000 and 2015, coal consumption fell by half.",
      },
    ],
    mistakes: [
      {
        wrong: "I have went to Singapore twice.",
        right: "I have been to Singapore twice.",
        note: "Sau have phải là V3 (gone/been), không dùng V2 went; nói về trải nghiệm từng đến nơi nào thì dùng have been to.",
      },
      {
        wrong: "Since 2010, the number of tourists increased.",
        right: "Since 2010, the number of tourists has increased.",
        note: "Since nối từ một mốc quá khứ đến hiện tại nên động từ chính dùng hiện tại hoàn thành.",
      },
      {
        wrong: "I have finished my degree in 2020.",
        right: "I finished my degree in 2020.",
        note: "Có năm cụ thể đã qua thì dùng quá khứ đơn, không dùng hiện tại hoàn thành.",
      },
      {
        wrong: "I live here since 2018.",
        right: "I have lived here since 2018.",
        note: "Tiếng Việt nói \"tôi sống ở đây từ 2018\" bằng hiện tại, nhưng tiếng Anh bắt buộc hiện tại hoàn thành khi có since/for kéo dài đến nay.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Over the last ten years, the price of housing ___ significantly.",
        options: ["rose", "has risen", "rises", "had risen"],
        answer: 1,
        explain:
          "\"Over the last ten years\" là khoảng thời gian kéo dài đến hiện tại nên dùng hiện tại hoàn thành. \"Rose\" sai vì không có mốc kết thúc trong quá khứ.",
      },
      {
        type: "choice",
        q: "I ___ this laptop since I started my first job.",
        options: ["have been owning", "own", "owned", "have owned"],
        answer: 3,
        explain:
          "Since + mốc quá khứ kéo dài đến nay dùng hiện tại hoàn thành. Own là động từ trạng thái nên không dùng dạng tiếp diễn \"have been owning\".",
      },
      {
        type: "choice",
        q: "She ___ her master's degree two years ago.",
        options: ["completed", "has completed", "has been completing", "completes"],
        answer: 0,
        explain:
          "\"Two years ago\" là mốc quá khứ xác định nên dùng quá khứ đơn. Hiện tại hoàn thành không bao giờ đi với ago.",
      },
      {
        type: "choice",
        q: "You look exhausted. ___ all night?",
        options: ["Did you work", "Have you been working", "Were you worked", "Do you work"],
        answer: 1,
        explain:
          "Nhấn mạnh một hoạt động kéo dài vừa kết thúc và để lại dấu hiệu ở hiện tại (trông mệt) dùng hiện tại hoàn thành tiếp diễn.",
      },
      {
        type: "choice",
        q: "My family has lived in this neighbourhood ___ twenty years.",
        options: ["since", "during", "for", "from"],
        answer: 2,
        explain:
          "\"Twenty years\" là một khoảng thời gian nên dùng for. Since chỉ đi với mốc thời gian (since 2005).",
      },
      {
        type: "choice",
        q: "Chọn câu đúng.",
        options: [
          "I have seen that film last week.",
          "I have ever seen that film.",
          "I saw that film last week.",
          "I have saw that film last week.",
        ],
        answer: 2,
        explain:
          "\"Last week\" là mốc quá khứ đã kết thúc nên dùng quá khứ đơn: saw. \"Have saw\" sai dạng V3; \"have ever seen\" không dùng ever trong câu khẳng định.",
      },
      {
        type: "fill",
        q: "Since 2015, the number of electric vehicles in Norway ___ sharply.",
        hint: "(rise)",
        answers: ["has risen", "'s risen", "has been rising", "'s been rising"],
        explain:
          "Since + mốc quá khứ kéo dài đến nay dùng hiện tại hoàn thành; chủ ngữ \"the number\" số ít nên dùng has. Quá khứ đơn \"rose\" là lỗi kinh điển.",
      },
      {
        type: "fill",
        q: "I ___ my essay yet, so I can't go out tonight.",
        hint: "(not finish)",
        answers: ["haven't finished", "have not finished"],
        explain:
          "Yet trong câu phủ định đi với hiện tại hoàn thành, và việc chưa xong ảnh hưởng tới hiện tại. \"Didn't finish ... yet\" chỉ gặp trong văn nói Anh-Mỹ thân mật, không nên dùng trong bài thi.",
      },
      {
        type: "fill",
        q: "Researchers ___ this disease for over thirty years and still have no cure.",
        hint: "(study)",
        answers: ["have been studying", "'ve been studying", "have studied", "'ve studied"],
        explain:
          "For + khoảng thời gian kéo dài đến nay dùng hiện tại hoàn thành; dạng tiếp diễn nhấn mạnh quá trình, dạng đơn cũng chấp nhận được. Không dùng \"study\" hay \"studied\".",
      },
      {
        type: "fill",
        q: "Have you ever ___ a presentation in English?",
        hint: "(give)",
        answers: ["given"],
        explain:
          "Sau have trong hiện tại hoàn thành phải là V3: given. \"Gave\" là V2, chỉ dùng cho quá khứ đơn.",
      },
    ],
  },

  // 4. Diễn đạt tương lai
  {
    id: "future-forms",
    group: "foundation",
    band: "5.0",
    title: "Các cách diễn đạt tương lai",
    en: "Future Forms",
    summary:
      "Tiếng Anh có nhiều cách nói về tương lai: will, be going to, hiện tại tiếp diễn, tương lai tiếp diễn và tương lai hoàn thành, mỗi cách mang sắc thái riêng. Bài này cũng luyện các cụm dự báo như \"is expected to\" dùng cho biểu đồ có số liệu tương lai ở Task 1.",
    rules: [
      {
        title: "Will: dự đoán, quyết định tức thời, lời hứa",
        body: "Will + V dùng cho dự đoán dựa trên ý kiến (thường với I think, probably), quyết định đưa ra ngay lúc nói, lời hứa hoặc đề nghị.",
        form: "S + will + V",
        examples: [
          {
            en: "I think artificial intelligence **will replace** many routine jobs.",
            vi: "Tôi nghĩ trí tuệ nhân tạo sẽ thay thế nhiều công việc lặp đi lặp lại.",
          },
          {
            en: "The phone is ringing. I**'ll answer** it.",
            vi: "Điện thoại đang reo. Để tôi nghe.",
          },
        ],
      },
      {
        title: "Be going to: dự định và dự đoán có căn cứ",
        body: "Be going to + V dùng cho kế hoạch đã quyết định từ trước, hoặc dự đoán dựa trên dấu hiệu hiện tại.",
        form: "S + am/is/are + going to + V",
        examples: [
          {
            en: "I**'m going to apply** for a master's degree next year.",
            vi: "Tôi dự định nộp hồ sơ học thạc sĩ vào năm sau.",
          },
          {
            en: "Look at those dark clouds. It**'s going to rain**.",
            vi: "Nhìn những đám mây đen kia kìa. Trời sắp mưa rồi.",
          },
        ],
      },
      {
        title: "Hiện tại tiếp diễn cho sự sắp xếp cố định",
        body: "Hiện tại tiếp diễn diễn tả lịch hẹn, sự sắp xếp đã chốt với người khác (thường có thời gian cụ thể).",
        form: "S + am/is/are + V-ing + thời gian tương lai",
        examples: [
          {
            en: "I**'m meeting** my supervisor on Friday afternoon.",
            vi: "Chiều thứ Sáu tôi có hẹn gặp người hướng dẫn.",
          },
          {
            en: "We**'re flying** to Tokyo next Monday.",
            vi: "Thứ Hai tới chúng tôi bay sang Tokyo.",
          },
        ],
      },
      {
        title: "Tương lai tiếp diễn và tương lai hoàn thành",
        body: "Tương lai tiếp diễn (future continuous) chỉ việc đang diễn ra tại một thời điểm tương lai. Tương lai hoàn thành (future perfect) chỉ việc sẽ hoàn tất trước một mốc tương lai, thường đi với by + thời gian.",
        form: "S + will be + V-ing | S + will have + V3",
        examples: [
          {
            en: "This time next year, I **will be working** in Singapore.",
            vi: "Giờ này năm sau tôi sẽ đang làm việc ở Singapore.",
          },
          {
            en: "By 2030, the city **will have built** three new bridges.",
            vi: "Đến năm 2030, thành phố sẽ xây xong ba cây cầu mới.",
          },
        ],
      },
      {
        title: "Cụm dự báo trang trọng",
        body: "Trong văn viết học thuật, dự báo thường dùng be expected to, be projected to, be predicted to, be forecast to + V. Các cụm này khách quan hơn will.",
        form: "S + is/are + expected/projected/predicted to + V",
        examples: [
          {
            en: "The global population **is expected to reach** 9.7 billion by 2050.",
            vi: "Dân số thế giới dự kiến đạt 9,7 tỷ người vào năm 2050.",
          },
          {
            en: "Demand for renewable energy **is projected to double** over the next two decades.",
            vi: "Nhu cầu năng lượng tái tạo được dự báo sẽ tăng gấp đôi trong hai thập kỷ tới.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip: "Khi biểu đồ có số liệu dự báo (sau năm hiện tại), đừng lặp will liên tục. Luân phiên is expected to, is projected to, is predicted to và will have + V3 với by.",
        example:
          "The proportion of elderly people is projected to rise to 25% by 2040, while the figure for children is expected to remain stable.",
      },
      {
        part: "Speaking",
        tip: "Câu hỏi về kế hoạch (Part 1: What are you going to do after graduation?) nên trả lời bằng be going to hoặc hiện tại tiếp diễn; dùng will cho dự đoán ở Part 3.",
        example:
          "I'm going to look for a job in marketing, and I'm starting an internship next month.",
      },
      {
        part: "Writing Task 2",
        tip: "Khi bàn về hệ quả tương lai, dùng will kèm từ giảm nhẹ (likely, probably) để lập luận thận trọng, học thuật hơn.",
        example:
          "If this trend continues, many rural areas will probably lose their younger population.",
      },
    ],
    mistakes: [
      {
        wrong: "I will to study abroad next year.",
        right: "I will study abroad next year.",
        note: "Sau will dùng động từ nguyên mẫu không có to.",
      },
      {
        wrong: "When I will finish university, I will travel.",
        right: "When I finish university, I will travel.",
        note: "Trong mệnh đề thời gian (when, after, as soon as, before) nói về tương lai, dùng hiện tại đơn chứ không dùng will.",
      },
      {
        wrong: "The number of users is expected to reaching 5 million.",
        right: "The number of users is expected to reach 5 million.",
        note: "Be expected to + động từ nguyên mẫu; to ở đây không phải giới từ.",
      },
      {
        wrong: "By 2030, the city will build ten new schools.",
        right: "By 2030, the city will have built ten new schools.",
        note: "By + mốc tương lai nhấn mạnh việc hoàn tất trước mốc đó nên dùng tương lai hoàn thành.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "I've already bought the tickets. We ___ the museum on Saturday.",
        options: ["will visit", "are visiting", "visit", "would visit"],
        answer: 1,
        explain:
          "Đã mua vé nghĩa là sự sắp xếp đã chốt nên dùng hiện tại tiếp diễn. \"Will visit\" hợp với quyết định tức thời hoặc dự đoán, không nhấn mạnh việc đã sắp xếp.",
      },
      {
        type: "choice",
        q: "Sales of electric cars ___ to overtake petrol cars by 2035.",
        options: ["are predicted", "predict", "will predict", "are predicting"],
        answer: 0,
        explain:
          "Cấu trúc bị động be predicted to + V: doanh số được dự báo sẽ vượt. \"Predict\" chủ động sai nghĩa vì doanh số không tự dự báo.",
      },
      {
        type: "choice",
        q: "Don't worry about the report. I ___ it to you tonight.",
        options: ["am sending", "send", "will send", "am going to sending"],
        answer: 2,
        explain:
          "Đây là lời hứa đưa ra ngay lúc nói nên dùng will. \"Am going to sending\" sai cấu trúc vì sau going to phải là động từ nguyên mẫu.",
      },
      {
        type: "choice",
        q: "By the end of this year, the company ___ more than 500 employees.",
        options: ["will hire", "hires", "is hiring", "will have hired"],
        answer: 3,
        explain:
          "\"By the end of this year\" là mốc hoàn tất trong tương lai nên dùng tương lai hoàn thành. \"Will hire\" không thể hiện việc xong trước mốc.",
      },
      {
        type: "choice",
        q: "As soon as the results ___ out, I will let you know.",
        options: ["will come", "come", "are coming", "will have come"],
        answer: 1,
        explain:
          "Sau as soon as (mệnh đề thời gian) nói về tương lai dùng hiện tại đơn: come. \"Will come\" là lỗi rất thường gặp do dịch từ tiếng Việt.",
      },
      {
        type: "choice",
        q: "Look at the traffic! We ___ late for the conference.",
        options: ["are going to be", "will being", "are being", "be"],
        answer: 0,
        explain:
          "Dự đoán dựa trên dấu hiệu hiện tại (tắc đường) dùng be going to. \"Will being\" sai cấu trúc.",
      },
      {
        type: "fill",
        q: "This time tomorrow, I ___ my IELTS Speaking test.",
        hint: "(take)",
        answers: ["will be taking", "'ll be taking"],
        explain:
          "\"This time tomorrow\" chỉ việc đang diễn ra tại một thời điểm tương lai nên dùng tương lai tiếp diễn: will be taking.",
      },
      {
        type: "fill",
        q: "The proportion of renewable energy is expected to ___ 40% by 2030.",
        hint: "(reach)",
        answers: ["reach"],
        explain:
          "Be expected to + động từ nguyên mẫu: reach. Không viết \"reaching\" hay \"reached\".",
      },
      {
        type: "fill",
        q: "I've decided what to do this summer: I ___ a coding course.",
        hint: "(take, kế hoạch đã quyết định)",
        answers: ["am going to take", "'m going to take", "am taking", "'m taking"],
        explain:
          "Kế hoạch đã quyết định từ trước dùng be going to + V (nếu đã đăng ký khoá học thì hiện tại tiếp diễn \"am taking\" cũng đúng). Will hợp hơn với quyết định đưa ra ngay lúc nói.",
      },
      {
        type: "fill",
        q: "By 2050, scientists ___ a cure for many types of cancer.",
        hint: "(find)",
        answers: ["will have found", "'ll have found"],
        explain:
          "By + mốc tương lai nhấn mạnh việc đã hoàn tất trước mốc đó nên dùng tương lai hoàn thành: will have found.",
      },
    ],
  },

  // 5. Mạo từ & danh từ
  {
    id: "articles-nouns",
    group: "foundation",
    band: "5.0",
    title: "Mạo từ và danh từ đếm được, không đếm được",
    en: "Articles & Countable/Uncountable Nouns",
    summary:
      "Tiếng Việt không có mạo từ và không chia số nhiều, nên đây là nhóm lỗi dày đặc nhất trong bài viết của người Việt. Bài này giúp dùng đúng a/an/the/không mạo từ và phân biệt danh từ đếm được với không đếm được.",
    rules: [
      {
        title: "A/an: lần đầu nhắc tới, một trong nhiều",
        body: "Dùng a/an trước danh từ đếm được số ít khi nhắc lần đầu hoặc nói về một cái bất kỳ. Chọn a hay an theo âm đầu, không theo chữ cái: a university, an hour, an MBA.",
        form: "a/an + danh từ đếm được số ít",
        examples: [
          {
            en: "My brother works for **an** international company.",
            vi: "Anh tôi làm cho một công ty quốc tế.",
          },
          {
            en: "She is studying at **a** university in Australia.",
            vi: "Cô ấy đang học ở một trường đại học tại Úc.",
          },
        ],
      },
      {
        title: "The: đã xác định",
        body: "Dùng the khi người nghe biết rõ đang nói về cái nào: đã nhắc trước đó, duy nhất (the internet, the environment, the government), có cụm bổ nghĩa xác định đi sau, hoặc trong so sánh nhất.",
        form: "the + danh từ đã xác định",
        examples: [
          {
            en: "**The** government should invest more in **the** healthcare system.",
            vi: "Chính phủ nên đầu tư nhiều hơn vào hệ thống y tế.",
          },
          {
            en: "**The** number of students who study online has doubled.",
            vi: "Số sinh viên học trực tuyến đã tăng gấp đôi.",
          },
          {
            en: "Tokyo is **the** largest city in **the** world.",
            vi: "Tokyo là thành phố lớn nhất thế giới.",
          },
        ],
      },
      {
        title: "Không mạo từ (zero article) khi nói chung chung",
        body: "Khi nói khái quát về một nhóm hay một khái niệm, dùng danh từ số nhiều hoặc danh từ không đếm được mà không có the.",
        form: "Danh từ số nhiều / không đếm được (không mạo từ)",
        examples: [
          {
            en: "**Children** learn languages faster than **adults**.",
            vi: "Trẻ em học ngôn ngữ nhanh hơn người lớn.",
          },
          {
            en: "**Technology** has transformed **education**.",
            vi: "Công nghệ đã làm thay đổi giáo dục.",
          },
        ],
      },
      {
        title: "Danh từ không đếm được thường gặp",
        body: "Information, advice, research, equipment, evidence, knowledge, furniture, traffic, homework, news không có dạng số nhiều và không đi với a/an. Muốn đếm thì dùng a piece of, an item of.",
        form: "a piece of + danh từ không đếm được",
        examples: [
          {
            en: "There is **a lot of evidence** that exercise improves mental health.",
            vi: "Có nhiều bằng chứng cho thấy tập thể dục cải thiện sức khoẻ tinh thần.",
          },
          {
            en: "My teacher gave me **a useful piece of advice**.",
            vi: "Giáo viên cho tôi một lời khuyên hữu ích.",
          },
          {
            en: "Hospitals need modern **equipment**.",
            vi: "Bệnh viện cần trang thiết bị hiện đại.",
          },
        ],
      },
      {
        title: "Much/many, a number of/the amount of",
        body: "Many, few, a number of, the number of đi với danh từ đếm được số nhiều. Much, little, the amount of đi với danh từ không đếm được.",
        form: "many/a number of + N số nhiều | much/the amount of + N không đếm được",
        examples: [
          {
            en: "**Many** people do not have **much** free time.",
            vi: "Nhiều người không có nhiều thời gian rảnh.",
          },
          {
            en: "**The amount of** waste produced by households has fallen.",
            vi: "Lượng rác thải các hộ gia đình tạo ra đã giảm.",
          },
          {
            en: "**The number of** cars in the city centre has risen.",
            vi: "Số lượng ô tô ở trung tâm thành phố đã tăng.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Khi nêu nhận định chung, viết danh từ số nhiều không mạo từ (Children, Governments, Young people) thay vì \"The children\". Kiểm tra lại mọi danh từ đếm được số ít trong bài: nó luôn cần a/an/the hoặc từ hạn định khác.",
        example:
          "Governments should provide free education because it benefits society as a whole.",
      },
      {
        part: "Writing Task 1",
        tip: "Dùng \"the number of\" với danh từ đếm được và \"the amount of\" với danh từ không đếm được; viết sai sẽ bị trừ điểm accuracy ngay câu đầu.",
        example:
          "The amount of electricity consumed rose steadily, while the number of households remained stable.",
      },
      {
        part: "Speaking",
        tip: "Các từ information, advice, research, equipment không bao giờ thêm -s. Nói \"some useful advice\" hoặc \"a piece of advice\".",
        example:
          "I did some research online, and my friends gave me some useful advice.",
      },
    ],
    mistakes: [
      {
        wrong: "She is teacher at high school.",
        right: "She is a teacher at a high school.",
        note: "Danh từ đếm được số ít không đứng một mình; tiếng Việt không có mạo từ nên người học hay bỏ a.",
      },
      {
        wrong: "The pollution is a serious problem in the modern society.",
        right: "Pollution is a serious problem in modern society.",
        note: "Nói chung chung về khái niệm không đếm được thì không dùng the.",
      },
      {
        wrong: "I need some informations and advices.",
        right: "I need some information and advice.",
        note: "Information và advice là danh từ không đếm được, không thêm -s.",
      },
      {
        wrong: "The number of water used has increased.",
        right: "The amount of water used has increased.",
        note: "Water không đếm được nên dùng the amount of, không dùng the number of.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "It took me ___ hour to finish the reading test.",
        options: ["a", "an", "the", "(không mạo từ)"],
        answer: 1,
        explain:
          "Hour bắt đầu bằng âm nguyên âm (h câm) nên dùng an. \"A\" sai vì quy tắc dựa vào âm, không dựa vào chữ cái.",
      },
      {
        type: "choice",
        q: "___ is essential for economic growth.",
        options: ["The education", "An education", "Education", "Educations"],
        answer: 2,
        explain:
          "Nói chung chung về giáo dục như một khái niệm dùng danh từ không đếm được không mạo từ. \"The education\" chỉ đúng khi xác định (the education of girls).",
      },
      {
        type: "choice",
        q: "The researchers collected a large ___ for their study.",
        options: ["amount of data", "number of data", "many data", "datas"],
        answer: 0,
        explain:
          "Data trong tiếng Anh học thuật thường dùng như danh từ không đếm được nên đi với amount of. \"Datas\" không tồn tại; \"number of data\" sai vì number of cần danh từ đếm được số nhiều.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng.",
        options: [
          "The scientists have found an evidence of water on Mars.",
          "Scientists have found evidences of water on Mars.",
          "Scientists have found an evidence of water on Mars.",
          "Scientists have found evidence of water on Mars.",
        ],
        answer: 3,
        explain:
          "Evidence không đếm được, không dùng an và không thêm -s. Nói chung về các nhà khoa học thì dùng Scientists không mạo từ.",
      },
      {
        type: "choice",
        q: "Ho Chi Minh City is ___ most populous city in Vietnam.",
        options: ["a", "the", "an", "(không mạo từ)"],
        answer: 1,
        explain:
          "So sánh nhất (most populous) luôn đi với the. \"A\" sai vì chỉ có một thành phố đông dân nhất.",
      },
      {
        type: "choice",
        q: "How ___ equipment does the new laboratory need?",
        options: ["many", "few", "a number of", "much"],
        answer: 3,
        explain:
          "Equipment là danh từ không đếm được nên dùng how much. \"Many\" chỉ đi với danh từ đếm được số nhiều.",
      },
      {
        type: "fill",
        q: "My tutor gave me a very useful piece of ___ about the Speaking test.",
        hint: "(advice)",
        answers: ["advice"],
        explain:
          "Advice không đếm được nên luôn ở dạng advice, kể cả sau a piece of. \"Advices\" là lỗi phổ biến.",
      },
      {
        type: "fill",
        q: "___ amount of plastic in the ocean is increasing every year.",
        hint: "(mạo từ)",
        answers: ["The"],
        explain:
          "Cụm \"the amount of\" luôn dùng the vì đã được xác định bởi cụm of phía sau. \"An amount of\" mang nghĩa khác (một lượng nào đó) và không hợp với câu nói về xu hướng.",
      },
      {
        type: "fill",
        q: "She wants to become ___ engineer after graduating.",
        hint: "(mạo từ)",
        answers: ["an"],
        explain:
          "Engineer là danh từ đếm được số ít chỉ nghề nghiệp, bắt đầu bằng âm nguyên âm nên dùng an. Không được bỏ mạo từ.",
      },
      {
        type: "fill",
        q: "There has been a lot of ___ into the effects of social media on teenagers.",
        hint: "(research)",
        answers: ["research"],
        explain:
          "Research là danh từ không đếm được nên không thêm -s, dù đi sau a lot of.",
      },
    ],
  },

  // 6. Hoà hợp chủ ngữ – động từ
  {
    id: "subject-verb-agreement",
    group: "foundation",
    band: "5.0",
    title: "Hoà hợp chủ ngữ và động từ",
    en: "Subject-Verb Agreement",
    summary:
      "Động từ phải chia theo chủ ngữ thật sự của câu, kể cả khi chủ ngữ dài, có số liệu hay bắt đầu bằng V-ing. Lỗi hoà hợp (subject-verb agreement) rất dễ thấy và làm giảm điểm accuracy ở cả Writing lẫn Speaking.",
    rules: [
      {
        title: "Every, each, everyone và chủ ngữ số ít",
        body: "Every, each, everyone, everybody, nobody, something đi với động từ số ít.",
        form: "Every/Each + N số ít + V(s)",
        examples: [
          {
            en: "Every student **has** access to the online library.",
            vi: "Mỗi sinh viên đều được dùng thư viện trực tuyến.",
          },
          {
            en: "Each of the countries **has** its own education system.",
            vi: "Mỗi quốc gia đều có hệ thống giáo dục riêng.",
          },
        ],
      },
      {
        title: "The number of và a number of",
        body: "The number of + N số nhiều (con số) đi với động từ số ít. A number of + N số nhiều (nhiều cái) đi với động từ số nhiều.",
        form: "The number of + N(s) + V số ít | A number of + N(s) + V số nhiều",
        examples: [
          {
            en: "The number of international students **has** grown.",
            vi: "Số lượng sinh viên quốc tế đã tăng.",
          },
          {
            en: "A number of universities **offer** online degrees.",
            vi: "Một số trường đại học cung cấp bằng cấp trực tuyến.",
          },
        ],
      },
      {
        title: "Chủ ngữ dài, cụm danh động từ, one of",
        body: "Tìm danh từ chính của chủ ngữ, bỏ qua cụm bổ nghĩa ở giữa. Danh động từ (V-ing) làm chủ ngữ đi với động từ số ít. \"One of the + N số nhiều\" vẫn chia số ít vì chủ ngữ là one.",
        form: "One of the + N(s) + V số ít | V-ing + V số ít",
        examples: [
          {
            en: "The quality of public services in rural areas **is** still low.",
            vi: "Chất lượng dịch vụ công ở vùng nông thôn vẫn còn thấp.",
          },
          {
            en: "Learning a foreign language **takes** time and patience.",
            vi: "Học ngoại ngữ cần thời gian và sự kiên nhẫn.",
          },
          {
            en: "One of the main problems in big cities **is** air pollution.",
            vi: "Một trong những vấn đề chính ở các thành phố lớn là ô nhiễm không khí.",
          },
        ],
      },
      {
        title: "There is/there are và phần trăm + of",
        body: "Với there is/are, động từ chia theo danh từ đứng sau. Với phần trăm, phân số hay most/some + of, động từ chia theo danh từ sau of: số ít/không đếm được dùng động từ số ít, số nhiều dùng động từ số nhiều.",
        form: "There is + N số ít/không đếm được | There are + N số nhiều | 40% of + N + V theo N",
        examples: [
          {
            en: "There **are** many reasons why people move abroad.",
            vi: "Có nhiều lý do khiến người ta ra nước ngoài sinh sống.",
          },
          {
            en: "Around 60% of the population **lives** in urban areas.",
            vi: "Khoảng 60% dân số sống ở khu vực đô thị.",
          },
          {
            en: "Over half of the respondents **were** satisfied with the service.",
            vi: "Hơn một nửa số người trả lời hài lòng với dịch vụ.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip: "Mỗi câu có phần trăm, hãy nhìn danh từ sau of để chia động từ. \"The proportion/percentage of + N\" thì luôn chia số ít vì chủ ngữ là proportion.",
        example:
          "The percentage of households with internet access was 30% in 2005, while 70% of adults were regular users.",
      },
      {
        part: "Writing Task 2",
        tip: "Câu lập luận hay có chủ ngữ dài. Trước khi nộp bài, gạch dưới danh từ chính của từng chủ ngữ và kiểm tra động từ.",
        example:
          "The growing number of cars on the roads is one of the main causes of pollution.",
      },
      {
        part: "Speaking",
        tip: "Nói nhanh dễ quên -s sau he/she/it và sau \"one of\". Luyện các khung câu cố định để tạo phản xạ.",
        example:
          "One of my favourite places is a small café near my office.",
      },
    ],
    mistakes: [
      {
        wrong: "The number of students have increased.",
        right: "The number of students has increased.",
        note: "Chủ ngữ thật là number (số ít), không phải students.",
      },
      {
        wrong: "One of my friends live in Canada.",
        right: "One of my friends lives in Canada.",
        note: "Chủ ngữ là one nên động từ chia số ít.",
      },
      {
        wrong: "There is many problems in big cities.",
        right: "There are many problems in big cities.",
        note: "Sau there, động từ chia theo danh từ đứng sau; problems số nhiều nên dùng are.",
      },
      {
        wrong: "Playing video games are bad for children.",
        right: "Playing video games is bad for children.",
        note: "Chủ ngữ là danh động từ playing nên chia số ít, không chia theo games.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "A number of employees ___ asked to work from home.",
        options: ["has", "is", "have", "was"],
        answer: 2,
        explain:
          "A number of + danh từ số nhiều mang nghĩa \"nhiều\" nên động từ chia số nhiều: have. Đừng nhầm với \"the number of\" chia số ít.",
      },
      {
        type: "choice",
        q: "The number of people living alone ___ risen sharply.",
        options: ["has", "have", "are", "were"],
        answer: 0,
        explain:
          "Chủ ngữ thật là \"the number\" (số ít) nên dùng has. \"Have\" là phương án dễ nhầm vì people đứng gần động từ.",
      },
      {
        type: "choice",
        q: "Every child in the country ___ the right to free education.",
        options: ["have", "having", "are having", "has"],
        answer: 3,
        explain:
          "Every + danh từ số ít đi với động từ số ít: has. \"Have\" sai dù nghĩa \"mọi trẻ em\" nghe như số nhiều.",
      },
      {
        type: "choice",
        q: "About 40% of the energy in this region ___ from coal.",
        options: ["come", "comes", "are coming", "have come"],
        answer: 1,
        explain:
          "Danh từ sau of là energy (không đếm được) nên động từ chia số ít: comes. \"Come\" sai vì 40% không quyết định số của động từ.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng.",
        options: [
          "The effects of climate change is becoming more visible.",
          "The effect of climate changes are becoming more visible.",
          "The effects of climate change are becoming more visible.",
          "The effects of climate change becomes more visible.",
        ],
        answer: 2,
        explain:
          "Danh từ chính là effects (số nhiều), cụm of climate change chỉ là bổ nghĩa, nên dùng are. Phương án đầu sai vì chia theo change.",
      },
      {
        type: "choice",
        q: "There ___ a lot of traffic in the city centre during rush hour.",
        options: ["are", "were being", "is", "have"],
        answer: 2,
        explain:
          "Traffic là danh từ không đếm được nên dùng there is. \"Are\" sai vì \"a lot of\" không làm danh từ thành số nhiều.",
      },
      {
        type: "fill",
        q: "One of the biggest challenges for young graduates ___ finding a stable job.",
        hint: "(be, hiện tại)",
        answers: ["is"],
        explain:
          "Chủ ngữ là one (số ít) nên dùng is. \"Are\" sai vì challenges và graduates chỉ là phần bổ nghĩa.",
      },
      {
        type: "fill",
        q: "Using public transport ___ air pollution in big cities.",
        hint: "(reduce, hiện tại đơn)",
        answers: ["reduces"],
        explain:
          "Danh động từ using làm chủ ngữ được coi là số ít nên động từ thêm -s: reduces.",
      },
      {
        type: "fill",
        q: "Over half of the students in the survey ___ that they study late at night.",
        hint: "(say, hiện tại đơn)",
        answers: ["say"],
        explain:
          "Với half of + danh từ, động từ chia theo danh từ sau of: students số nhiều nên dùng say. \"Says\" sai vì half không quyết định số của động từ.",
      },
      {
        type: "fill",
        q: "Each of the three proposals ___ advantages and disadvantages.",
        hint: "(have, hiện tại)",
        answers: ["has"],
        explain:
          "\"Each of + danh từ số nhiều\" vẫn chia số ít vì chủ ngữ là each: has. \"Have\" là lỗi do chia theo proposals.",
      },
    ],
  },
];
