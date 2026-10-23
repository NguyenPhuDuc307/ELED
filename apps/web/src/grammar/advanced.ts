import type { GrammarUnit } from "./types";

export const advanced: GrammarUnit[] = [
  // 1. Mệnh đề phân từ & rút gọn mệnh đề
  {
    id: "participle-clauses",
    group: "advanced",
    band: "7.0",
    title: "Mệnh đề phân từ & rút gọn mệnh đề",
    en: "Participle Clauses & Reduced Clauses",
    summary:
      "Mệnh đề phân từ (participle clause) giúp gộp hai ý thành một câu gọn, liền mạch mà không cần liên từ. Dùng chính xác, đặc biệt là tránh lỗi chủ ngữ treo (dangling participle), là dấu hiệu rõ của band 7+ ở tiêu chí Grammatical Range and Accuracy.",
    rules: [
      {
        title: "Phân từ hiện tại (present participle, V-ing)",
        body: "Dùng V-ing khi chủ ngữ ngầm tự thực hiện hành động (nghĩa chủ động). Mệnh đề V-ing có thể diễn tả hành động đồng thời, nguyên nhân, hoặc hệ quả đứng sau dấu phẩy. Chủ ngữ ngầm của V-ing phải trùng với chủ ngữ mệnh đề chính.",
        form: "V-ing ..., S + V   |   S + V ..., V-ing ... (hệ quả)",
        examples: [
          {
            en: "**Living** in overcrowded cities, many young people struggle to afford housing.",
            vi: "Sống ở những thành phố quá đông đúc, nhiều người trẻ chật vật mới đủ tiền lo chỗ ở.",
          },
          {
            en: "**Realising** the scale of the problem, the government introduced a nationwide recycling scheme.",
            vi: "Nhận ra quy mô của vấn đề, chính phủ đã triển khai chương trình tái chế trên toàn quốc.",
          },
          {
            en: "Online learning has expanded rapidly, **giving** students far more flexibility.",
            vi: "Học trực tuyến mở rộng nhanh chóng, mang lại cho sinh viên sự linh hoạt lớn hơn nhiều.",
          },
        ],
      },
      {
        title: "Phân từ quá khứ (past participle, V3)",
        body: "Dùng V3 khi chủ ngữ ngầm chịu tác động của hành động (nghĩa bị động). Mệnh đề V3 thường thay cho mệnh đề bị động chỉ nguyên nhân, thời gian hoặc điều kiện.",
        form: "V3 ..., S + V",
        examples: [
          {
            en: "**Built** in the 1960s, many of these apartment blocks are now unsafe.",
            vi: "Được xây từ những năm 1960, nhiều khu chung cư này hiện đã không còn an toàn.",
          },
          {
            en: "**Funded** by the state, public universities can keep tuition fees low.",
            vi: "Nhờ được nhà nước tài trợ, các trường đại học công lập có thể giữ học phí ở mức thấp.",
          },
          {
            en: "**Used** responsibly, social media can be a valuable educational tool.",
            vi: "Nếu được sử dụng có trách nhiệm, mạng xã hội có thể là một công cụ giáo dục hữu ích.",
          },
        ],
      },
      {
        title: "Phân từ hoàn thành (perfect participle)",
        body: "Having + V3 (chủ động) hoặc Having been + V3 (bị động) nhấn mạnh hành động trong mệnh đề phân từ đã xong trước hành động ở mệnh đề chính.",
        form: "Having + V3 ..., S + V   |   Having been + V3 ..., S + V",
        examples: [
          {
            en: "**Having completed** their degrees, many graduates still find it difficult to secure stable employment.",
            vi: "Dù đã hoàn thành chương trình đại học, nhiều sinh viên tốt nghiệp vẫn khó tìm được việc làm ổn định.",
          },
          {
            en: "**Having been criticised** for years, the policy was finally abandoned.",
            vi: "Sau nhiều năm bị chỉ trích, chính sách này cuối cùng cũng bị bãi bỏ.",
          },
        ],
      },
      {
        title: "Rút gọn mệnh đề quan hệ (reduced relative clause)",
        body: "Bỏ đại từ quan hệ (who/which/that) và động từ be: mệnh đề chủ động chuyển thành V-ing, mệnh đề bị động chuyển thành V3. Không dùng V-ing để rút gọn một hành động đơn lẻ đã hoàn tất trong quá khứ.",
        form: "N + V-ing (= who/which + V chủ động)   |   N + V3 (= who/which + be + V3)",
        examples: [
          {
            en: "Students **living** in rural areas often have limited access to the internet.",
            vi: "Học sinh sống ở vùng nông thôn thường ít có điều kiện tiếp cận Internet.",
          },
          {
            en: "The figures **collected** in the survey suggest a clear decline in smoking.",
            vi: "Số liệu thu thập trong cuộc khảo sát cho thấy tỉ lệ hút thuốc giảm rõ rệt.",
          },
          {
            en: "Most of the waste **produced** by households ends up in landfill.",
            vi: "Phần lớn rác thải do các hộ gia đình thải ra cuối cùng bị đem đi chôn lấp.",
          },
        ],
      },
      {
        title: "Tránh chủ ngữ treo; các cụm cố định",
        body: "Nếu chủ ngữ mệnh đề chính không phải là người/vật thực hiện hành động phân từ, câu bị lỗi chủ ngữ treo (dangling participle) và thường nghe vô lý. Riêng một số cụm như Compared with/to, Given (that), Generally speaking, Considering đã thành giới từ/liên từ cố định nên không cần chủ ngữ trùng khớp.",
        form: "Compared with/to + N, S + V   |   Given (that) + mệnh đề / Given + N, S + V",
        examples: [
          {
            en: "**Compared with** the 1990s, far fewer adults smoke today.",
            vi: "So với những năm 1990, ngày nay số người trưởng thành hút thuốc ít hơn hẳn.",
          },
          {
            en: "**Given that** most jobs now require digital skills, schools should teach coding from an early age.",
            vi: "Vì hầu hết công việc hiện nay đều đòi hỏi kỹ năng số, nhà trường nên dạy lập trình từ sớm.",
          },
          {
            en: "**Walking** to school, I got caught in the rain.",
            vi: "Trên đường đi bộ đến trường, tôi bị mắc mưa. (Chủ ngữ \"I\" chính là người đi bộ, nên câu đúng.)",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Dùng 1–2 mệnh đề phân từ để nối nguyên nhân – kết quả trong đoạn thân bài, thay cho chuỗi câu đơn nối bằng and/so. Giám khảo thưởng điểm cho cấu trúc phức được dùng chính xác và tự nhiên, không phải cho việc nhồi nhét; luôn kiểm tra chủ ngữ ngầm có trùng chủ ngữ chính không.",
        example:
          "Faced with rising living costs, many young couples are choosing to delay having children.",
      },
      {
        part: "Writing Task 1",
        tip: "Cụm \", + V-ing\" rất hiệu quả để nối một xu hướng với mốc số liệu; Compared with/to giúp so sánh gọn hai mốc thời gian.",
        example:
          "The number of visitors rose steadily after 2010, reaching a peak of 2 million in 2018.",
      },
      {
        part: "Speaking",
        tip: "Trong Speaking không cần cố dùng mệnh đề phân từ; một câu tự nhiên như Having grown up in... là đủ để thể hiện độ đa dạng. Câu ép buộc, sai chủ ngữ sẽ bị trừ điểm Accuracy.",
        example: "Having grown up in Hanoi, I'm quite used to heavy traffic.",
      },
    ],
    mistakes: [
      {
        wrong: "Walking to school, the rain started.",
        right: "While I was walking to school, it started to rain.",
        note: "Chủ ngữ treo: câu sai hiểu thành \"cơn mưa đi bộ đến trường\" vì chủ ngữ chính là the rain.",
      },
      {
        wrong: "Having finished the report, the computer was switched off.",
        right: "Having finished the report, I switched off the computer.",
        note: "Người viết báo cáo là \"tôi\", không phải cái máy tính, nên chủ ngữ chính phải là I.",
      },
      {
        wrong: "The number of people used public transport rose steadily.",
        right: "The number of people using public transport rose steadily.",
        note: "Rút gọn mệnh đề chủ động phải dùng V-ing; giữ used khiến câu có hai động từ chính.",
      },
      {
        wrong: "Compare with last year, sales increased by 10%.",
        right: "Compared with last year, sales increased by 10%.",
        note: "Cụm cố định là Compared with/to (V3), không dùng động từ nguyên thể compare.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "___ by the government, the new metro line will open in 2027.",
        options: ["Funding", "Funded", "Having funded", "To fund"],
        answer: 1,
        explain:
          "Tuyến metro được chính phủ tài trợ (nghĩa bị động, có by the government) nên dùng V3 Funded. Funding và Having funded mang nghĩa chủ động, như thể tuyến metro tự đi tài trợ cho ai đó.",
      },
      {
        type: "choice",
        q: "___ the survey, the researchers published their findings in a leading journal.",
        options: ["Completed", "Having been completed", "Being completed", "Having completed"],
        answer: 3,
        explain:
          "Các nhà nghiên cứu tự hoàn thành khảo sát (chủ động) trước khi công bố, nên dùng Having completed. Completed và Having been completed là bị động, khiến câu hiểu thành các nhà nghiên cứu bị hoàn thành.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng ngữ pháp:",
        options: [
          "Looking out of the window, the traffic was terrible.",
          "Looked out of the window, I saw heavy traffic.",
          "Having looking out of the window, I saw heavy traffic.",
          "Looking out of the window, I saw that the traffic was terrible.",
        ],
        answer: 3,
        explain:
          "Chủ ngữ I chính là người nhìn ra cửa sổ nên câu cuối đúng. Câu đầu dễ chọn nhầm nhưng mắc lỗi chủ ngữ treo (giao thông không thể nhìn ra cửa sổ); Looked mang nghĩa bị động; Having looking sai dạng (phải là Having looked).",
      },
      {
        type: "choice",
        q: "Most of the plastic ___ in Vietnam is not recycled.",
        options: ["produced", "producing", "is produced", "which producing"],
        answer: 0,
        explain:
          "Nhựa được sản xuất ra (bị động) nên rút gọn which is produced thành produced. Producing mang nghĩa chủ động (nhựa tự sản xuất); is produced tạo ra hai động từ chính; which producing sai vì đã giữ which thì phải chia động từ.",
      },
      {
        type: "choice",
        q: "Tourist numbers rose steadily throughout the decade, ___ a peak of 4 million in 2019.",
        options: ["reached", "to have reached", "reaching", "having been reached"],
        answer: 2,
        explain:
          "Cụm \", + V-ing\" diễn tả hệ quả/diễn biến tiếp theo của cùng chủ ngữ (tourist numbers), nên dùng reaching. Reached sau dấu phẩy tạo thành hai mệnh đề không có liên từ; having been reached là bị động, sai nghĩa.",
      },
      {
        type: "choice",
        q: "___ that most jobs now require digital skills, coding should be taught at primary level.",
        options: ["Given", "Giving", "Give", "Being given"],
        answer: 0,
        explain:
          "Given that là cụm liên từ cố định nghĩa \"xét rằng, vì\", không cần chủ ngữ trùng khớp. Giving that không tồn tại với nghĩa này; Give và Being given đều sai cấu trúc.",
      },
      {
        type: "fill",
        q: "People ___ in large cities are more likely to suffer from stress-related illnesses.",
        hint: "(live) – một từ",
        answers: ["living"],
        explain:
          "Rút gọn who live (chủ động) thành living. Nếu viết live hoặc lived, câu sẽ có hai động từ chính (live và are).",
      },
      {
        type: "fill",
        q: "___ for years, the old factory was finally turned into a public library.",
        hint: "(abandon)",
        answers: ["having been abandoned", "abandoned"],
        explain:
          "Nhà máy bị bỏ hoang (bị động) trong nhiều năm trước khi được cải tạo, nên dùng Having been abandoned hoặc ngắn gọn Abandoned. Abandoning hay Having abandoned là chủ động, sai nghĩa.",
      },
      {
        type: "fill",
        q: "___ with other forms of transport, cycling produces almost no emissions.",
        hint: "(compare)",
        answers: ["compared"],
        explain:
          "Cụm cố định là Compared with/to. Comparing with... sẽ thành chủ ngữ treo vì xe đạp không tự đi so sánh.",
      },
      {
        type: "fill",
        q: "Many students work part-time, ___ them little time to study.",
        hint: "(leave)",
        answers: ["leaving"],
        explain:
          "Mệnh đề \", + V-ing\" diễn tả hệ quả của cả vế trước (việc đi làm thêm khiến họ còn ít thời gian học). Left sẽ sai vì không có liên từ nối hai động từ chính.",
      },
    ],
  },

  // 2. Danh từ hoá
  {
    id: "nominalisation",
    group: "advanced",
    band: "7.0",
    title: "Danh từ hoá",
    en: "Nominalisation",
    summary:
      "Danh từ hoá (nominalisation) là chuyển động từ hoặc tính từ thành danh từ để câu văn khách quan, cô đọng và mang văn phong học thuật hơn. Đây là công cụ mạnh trong Writing, nhưng lạm dụng sẽ khiến câu nặng nề, khó hiểu.",
    rules: [
      {
        title: "Động từ → danh từ",
        body: "Biến hành động thành một khái niệm để làm chủ ngữ hoặc tân ngữ: decide → decision, grow → growth, consume → consumption, introduce → introduction, reduce → reduction. Tác nhân chuyển thành sở hữu cách ('s) hoặc cụm by/of.",
        form: "S + V + O  →  S's + N + of/to ...  |  the + N + of + O",
        examples: [
          {
            en: "**The government's decision** to raise fuel taxes was deeply unpopular.",
            vi: "Quyết định tăng thuế nhiên liệu của chính phủ vấp phải sự phản đối mạnh mẽ.",
          },
          {
            en: "**The rapid growth of** online shopping has forced many small shops to close.",
            vi: "Sự phát triển nhanh chóng của mua sắm trực tuyến đã buộc nhiều cửa hàng nhỏ phải đóng cửa.",
          },
          {
            en: "**The introduction of** congestion charges has reduced traffic in central London.",
            vi: "Việc áp dụng phí chống ùn tắc đã làm giảm lưu lượng xe ở trung tâm London.",
          },
        ],
      },
      {
        title: "Tính từ → danh từ",
        body: "Chuyển tính từ thành danh từ để nói về một đặc tính hay tình trạng chung: available → availability, aware → awareness, important → importance, poor → poverty, able → ability, safe → safety.",
        form: "S + be + adj  →  the/a + (adj) + N + of ...",
        examples: [
          {
            en: "**The limited availability of** healthy food in some areas contributes to obesity.",
            vi: "Việc thực phẩm lành mạnh khó tìm ở một số khu vực góp phần gây ra béo phì.",
          },
          {
            en: "**A lack of public awareness** remains the main obstacle to recycling.",
            vi: "Nhận thức hạn chế của người dân vẫn là trở ngại lớn nhất đối với việc tái chế.",
          },
        ],
      },
      {
        title: "Mệnh đề → cụm danh từ sau giới từ",
        body: "Thay mệnh đề nguyên nhân (because + S + V) bằng giới từ + cụm danh từ (due to, because of, owing to, as a result of). Khi đó trạng từ thường đổi thành tính từ: consume more → increased consumption, rise sharply → a sharp rise.",
        form: "because + S + V (+ adv)  →  due to / owing to + (adj) + N",
        examples: [
          {
            en: "Emissions have risen **due to increased consumption** of meat.",
            vi: "Lượng khí thải tăng lên do mức tiêu thụ thịt ngày càng cao.",
          },
          {
            en: "Air quality has worsened **as a result of the rapid expansion of** private car ownership.",
            vi: "Chất lượng không khí xấu đi do số người sở hữu ô tô riêng tăng nhanh.",
          },
          {
            en: "**Owing to a sharp decline in** birth rates, many rural schools have closed.",
            vi: "Do tỉ lệ sinh giảm mạnh, nhiều trường học ở nông thôn đã phải đóng cửa.",
          },
        ],
      },
      {
        title: "Danh từ hoá để liên kết câu (cohesion)",
        body: "Gói ý của câu trước thành một danh từ và dùng nó làm chủ ngữ câu sau (This ban, This rise, Such growth). Cách này giúp đoạn văn mạch lạc mà không lặp lại nguyên câu.",
        form: "Câu 1: S + V ...  →  Câu 2: This/Such + N + V ...",
        examples: [
          {
            en: "Many cities have banned single-use plastics. **This ban** has significantly reduced marine pollution.",
            vi: "Nhiều thành phố đã cấm đồ nhựa dùng một lần. Lệnh cấm này đã giảm đáng kể ô nhiễm biển.",
          },
          {
            en: "Graduate unemployment rose sharply last year. **This rise** has led many to question the value of a degree.",
            vi: "Năm ngoái tỉ lệ thất nghiệp của sinh viên tốt nghiệp tăng mạnh. Sự gia tăng này khiến nhiều người đặt câu hỏi về giá trị của tấm bằng đại học.",
          },
        ],
      },
      {
        title: "Đừng lạm dụng danh từ hoá",
        body: "Chuỗi nhiều danh từ nối bằng of (the implementation of the reduction of the consumption of...) làm câu mơ hồ, mất tác nhân và khó đọc. Khi ai làm gì đã rõ ràng, dùng động từ thường dễ hiểu và thuyết phục hơn; câu hay là câu phối hợp cả hai.",
        examples: [
          {
            en: "**Governments should invest** in public transport to reduce congestion.",
            vi: "Chính phủ nên đầu tư vào giao thông công cộng để giảm ùn tắc. (Rõ ràng hơn hẳn kiểu viết toàn danh từ: The investment of governments in public transport for the reduction of congestion is a necessity.)",
          },
          {
            en: "**The rise in** childhood obesity is largely because children **exercise less** than before.",
            vi: "Tình trạng béo phì ở trẻ em gia tăng phần lớn là do trẻ vận động ít hơn trước. (Kết hợp một danh từ hoá với một động từ thường.)",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip: "Mô tả xu hướng bằng cụm danh từ (a sharp increase in, a gradual decline in) xen kẽ với động từ (increase sharply, decline gradually) để đa dạng cấu trúc mà không lặp từ.",
        example:
          "There was a dramatic increase in the consumption of renewable energy between 2010 and 2020.",
      },
      {
        part: "Writing Task 2",
        tip: "Dùng danh từ hoá cho câu chủ đề (topic sentence) và để nối ý giữa các câu (This trend, Such measures). Mỗi câu chỉ nên có một cụm danh từ hoá chính; câu nào phải đọc lại mới hiểu là đã quá tay.",
        example:
          "The widespread use of smartphones among teenagers has raised serious concerns about their mental health.",
      },
      {
        part: "Speaking",
        tip: "Trong Speaking, nói bằng động từ tự nhiên hơn nhiều. Danh từ hoá dày đặc nghe như đọc bài viết thuộc lòng, ảnh hưởng tới Fluency and Coherence.",
        example: "I think people are buying more online mainly because it's so convenient.",
      },
    ],
    mistakes: [
      {
        wrong: "The develop of technology has changed education.",
        right: "The development of technology has changed education.",
        note: "Sau The và trước of phải là danh từ (development), không dùng động từ nguyên thể develop.",
      },
      {
        wrong: "Due to people consume more meat, greenhouse gas emissions have risen.",
        right: "Due to increased meat consumption, greenhouse gas emissions have risen.",
        note: "Due to là giới từ nên phải đi với cụm danh từ; muốn giữ mệnh đề thì dùng Because people consume more meat.",
      },
      {
        wrong: "The government's decision of raising taxes was unpopular.",
        right: "The government's decision to raise taxes was unpopular.",
        note: "Danh từ decision đi với to-V, giống động từ decide to do.",
      },
      {
        wrong: "The reduction of the use of cars by the encouragement of the use of bicycles is a solution.",
        right: "Encouraging people to cycle would reduce car use.",
        note: "Chồng quá nhiều danh từ + of khiến câu nặng nề, khó hiểu; dùng động từ sẽ rõ ràng hơn.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "___ of fossil fuels is the main cause of air pollution in many cities.",
        options: ["The burn", "Burnt", "The burning", "To burning"],
        answer: 2,
        explain:
          "Cần một danh từ làm chủ ngữ trước of: The burning of fossil fuels (danh động từ dùng như danh từ). The burn không mang nghĩa \"việc đốt\" ở đây; Burnt là phân từ; To burning sai cấu trúc.",
      },
      {
        type: "choice",
        q: "Many species are under threat ___ the destruction of their natural habitats.",
        options: ["because", "due to", "although", "because they"],
        answer: 1,
        explain:
          "Phía sau là cụm danh từ (the destruction of...), nên cần giới từ due to. Because chỉ đi với mệnh đề có chủ ngữ và động từ; although sai nghĩa.",
      },
      {
        type: "choice",
        q: "Chọn cách danh từ hoá đúng và tự nhiên nhất cho câu: 'Prices rose sharply, so many families struggled.'",
        options: [
          "The sharply rise of prices meant that many families struggled.",
          "The rise sharply in prices meant that many families struggled.",
          "The sharp rising prices meant that many families struggled.",
          "The sharp rise in prices meant that many families struggled.",
        ],
        answer: 3,
        explain:
          "Khi danh từ hoá rise sharply, trạng từ sharply phải đổi thành tính từ sharp đứng trước danh từ: the sharp rise in prices (rise đi với in). Phương án đầu giữ trạng từ trước danh từ; phương án thứ ba thiếu -ly (phải là sharply rising).",
      },
      {
        type: "choice",
        q: "There has been a significant ___ in the number of students studying abroad.",
        options: ["increase", "increasing", "increased", "increasingly"],
        answer: 0,
        explain:
          "Sau mạo từ a và tính từ significant cần một danh từ: increase. Increased là tính từ/phân từ, increasingly là trạng từ, increasing không dùng làm danh từ trong cấu trúc này.",
      },
      {
        type: "choice",
        q: "Chọn câu rõ ràng và tự nhiên nhất:",
        options: [
          "The improvement of the quality of the provision of education is a need of the government.",
          "The government's need is the improvement of education quality provision.",
          "The government needs to improve the quality of education.",
          "The government needs improvement the quality of education.",
        ],
        answer: 2,
        explain:
          "Câu thứ ba dùng động từ, rõ ai làm gì. Hai câu đầu đúng từ vựng nhưng lạm dụng danh từ hoá nên rối và thiếu tự nhiên; câu cuối sai ngữ pháp vì improvement không thể nhận tân ngữ trực tiếp.",
      },
      {
        type: "choice",
        q: "The government's ___ to ban petrol cars by 2035 has been widely debated.",
        options: ["decide", "decision", "decisive", "deciding"],
        answer: 1,
        explain:
          "Sau sở hữu cách The government's cần danh từ: decision (đi với to-V). Decisive là tính từ; deciding không dùng làm danh từ đếm được trong cấu trúc này.",
      },
      {
        type: "fill",
        q: "Lack of sleep can affect students' ___ to concentrate.",
        hint: "(able)",
        answers: ["ability"],
        explain:
          "Sau sở hữu cách students' cần danh từ của able là ability (ability to do something). Able là tính từ nên không đứng ở vị trí này.",
      },
      {
        type: "fill",
        q: "Recent years have seen a dramatic ___ in the number of people working from home.",
        hint: "(grow)",
        answers: ["growth"],
        explain:
          "Sau a dramatic cần danh từ: growth (growth in + số lượng). Grow là động từ, growing không dùng sau mạo từ a theo cách này.",
      },
      {
        type: "fill",
        q: "Many people are unaware of the ___ of a balanced diet.",
        hint: "(important)",
        answers: ["importance"],
        explain:
          "The ... of cần một danh từ: importance là danh từ của important. Giữ nguyên tính từ important là sai từ loại.",
      },
      {
        type: "fill",
        q: "Air quality has improved due to the ___ of stricter emission standards.",
        hint: "(introduce)",
        answers: ["introduction"],
        explain:
          "Due to là giới từ nên phải theo sau là cụm danh từ: the introduction of. Viết introduce hay introducing sau the ... of đều sai từ loại.",
      },
    ],
  },

  // 3. Ngôn ngữ thận trọng
  {
    id: "hedging",
    group: "advanced",
    band: "7.0",
    title: "Ngôn ngữ thận trọng (hedging)",
    en: "Hedging",
    summary:
      "Ngôn ngữ thận trọng (hedging) giúp tránh khẳng định tuyệt đối và khái quát hoá quá mức (overgeneralisation), một lỗi lập luận rất phổ biến trong Writing Task 2. Dùng đúng mức giúp bài viết khách quan, thuyết phục và mang giọng học thuật.",
    rules: [
      {
        title: "Động từ khuyết thiếu (modal verbs): may, might, could",
        body: "Diễn tả khả năng chứ không phải sự thật chắc chắn. Might thận trọng hơn may một chút; could thường dùng để nêu khả năng hoặc giải pháp. Sau modal là động từ nguyên thể không to.",
        form: "S + may/might/could + V (nguyên thể)",
        examples: [
          {
            en: "Excessive screen time **may affect** children's ability to concentrate.",
            vi: "Dùng màn hình quá nhiều có thể ảnh hưởng đến khả năng tập trung của trẻ.",
          },
          {
            en: "Remote work **could reduce** traffic congestion in major cities.",
            vi: "Làm việc từ xa có thể giúp giảm ùn tắc giao thông ở các thành phố lớn.",
          },
          {
            en: "Higher taxes on sugary drinks **might encourage** healthier eating habits.",
            vi: "Đánh thuế cao hơn vào đồ uống có đường có lẽ sẽ khuyến khích thói quen ăn uống lành mạnh hơn.",
          },
        ],
      },
      {
        title: "Động từ thận trọng: tend to, appear to, seem to, suggest",
        body: "Tend to nói về xu hướng chung; appear/seem to cho thấy đây là nhận định dựa trên quan sát; suggest/indicate dùng khi nói số liệu hay nghiên cứu cho thấy điều gì.",
        form: "S + tend/appear/seem + to V   |   It appears/seems that + mệnh đề   |   S + suggest(s) that + mệnh đề",
        examples: [
          {
            en: "Students who study abroad **tend to be** more independent.",
            vi: "Sinh viên du học thường có xu hướng tự lập hơn.",
          },
          {
            en: "Public transport **appears to be** more popular among younger commuters.",
            vi: "Giao thông công cộng có vẻ được những người đi làm trẻ tuổi ưa chuộng hơn.",
          },
          {
            en: "The data **suggest that** the policy has had a limited impact.",
            vi: "Số liệu cho thấy chính sách này chỉ có tác động hạn chế.",
          },
        ],
      },
      {
        title: "Cấu trúc với likely, possible, probable",
        body: "It is likely/possible/probable that + mệnh đề, hoặc S + be + likely to + V. Lưu ý: possible không dùng với chủ ngữ người/vật + to V (không nói Cars are possible to...).",
        form: "It is likely/possible that + mệnh đề   |   S + be + likely to + V",
        examples: [
          {
            en: "**It is likely that** automation will replace many routine jobs.",
            vi: "Nhiều khả năng tự động hoá sẽ thay thế nhiều công việc mang tính lặp lại.",
          },
          {
            en: "Electric cars **are likely to become** cheaper over the next decade.",
            vi: "Ô tô điện nhiều khả năng sẽ rẻ hơn trong thập kỷ tới.",
          },
          {
            en: "**It is possible that** online courses will never fully replace classroom teaching.",
            vi: "Có thể các khoá học trực tuyến sẽ không bao giờ thay thế hoàn toàn việc dạy học trên lớp.",
          },
        ],
      },
      {
        title: "Giới hạn phạm vi: lượng từ và trạng từ",
        body: "Thay all/everyone/always bằng many, most, a significant proportion of, in many cases; dùng to some extent, arguably, generally để làm mềm nhận định. Đây là cách trực tiếp nhất để tránh khái quát hoá quá mức.",
        examples: [
          {
            en: "**A significant proportion of** young people now rely on social media for news.",
            vi: "Một tỉ lệ đáng kể người trẻ hiện nay dựa vào mạng xã hội để cập nhật tin tức.",
          },
          {
            en: "**To some extent**, the internet has made people more isolated.",
            vi: "Ở một mức độ nào đó, Internet đã khiến con người trở nên cô lập hơn.",
          },
          {
            en: "**Arguably**, investing in education is the most effective way to reduce poverty.",
            vi: "Có thể nói rằng đầu tư vào giáo dục là cách hiệu quả nhất để giảm nghèo.",
          },
        ],
      },
      {
        title: "Làm mềm ý kiến nhưng vẫn giữ lập trường",
        body: "Trong Speaking, các cụm như I'd say, I suppose, it depends on, I tend to think giúp câu trả lời tự nhiên. Tuy vậy, không nên rào đón mọi câu: Task 2 vẫn cần một quan điểm rõ ràng xuyên suốt (Task Response).",
        examples: [
          {
            en: "**I'd say** most people in my city prefer motorbikes to cars.",
            vi: "Tôi nghĩ phần lớn người dân thành phố tôi thích xe máy hơn ô tô.",
          },
          {
            en: "**I suppose it depends on** the kind of job you're looking for.",
            vi: "Tôi cho là điều đó còn tuỳ vào loại công việc bạn đang tìm.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Rà lại bài để thay các từ tuyệt đối (all, everyone, always, never) bằng lượng từ và động từ thận trọng. Giám khảo coi khái quát hoá quá mức là điểm yếu lập luận, còn hedging đúng chỗ thể hiện tư duy học thuật.",
        example:
          "Many teenagers seem to spend more time online than with their families.",
      },
      {
        part: "Writing Task 2",
        tip: "Hedge các luận điểm phụ, nhưng giữ câu luận đề (thesis) rõ ràng. Rào đón quá mức như Perhaps it may possibly... khiến bài thiếu lập trường và bị trừ điểm Task Response.",
        example:
          "Although technology may have some drawbacks, I firmly believe that its benefits for education outweigh them.",
      },
      {
        part: "Speaking",
        tip: "Ở Part 3, dùng I'd say, probably, it seems to me that khi đưa ra giải thích hay dự đoán; câu trả lời vừa tự nhiên vừa thể hiện được độ đa dạng ngữ pháp.",
        example:
          "I'd say it's probably because young people have more opportunities in big cities.",
      },
    ],
    mistakes: [
      {
        wrong: "Everyone uses social media nowadays.",
        right: "Most people use social media nowadays.",
        note: "Khẳng định tuyệt đối dễ bị bác bỏ; dùng lượng từ như most, many để chính xác hơn.",
      },
      {
        wrong: "Automation is likely replace many jobs.",
        right: "Automation is likely to replace many jobs.",
        note: "Cấu trúc đúng là be likely to + V; không được bỏ to.",
      },
      {
        wrong: "Students tend to studying online more than before.",
        right: "Students tend to study online more than before.",
        note: "To trong tend to là một phần của động từ nguyên thể nên theo sau là V nguyên thể, không phải V-ing.",
      },
      {
        wrong: "Perhaps it may possibly lead to higher unemployment.",
        right: "It may lead to higher unemployment.",
        note: "Chồng ba từ thận trọng làm câu rườm rà và thiếu lập trường; một từ là đủ.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Chọn câu thận trọng và đúng ngữ pháp nhất cho bài Writing Task 2:",
        options: [
          "All young people are addicted to social media.",
          "Young people tend to spending too much time on social media.",
          "Many young people appear to spend too much time on social media.",
          "Many young people are appear to spend too much time on social media.",
        ],
        answer: 2,
        explain:
          "Câu thứ ba vừa giới hạn phạm vi (many) vừa dùng động từ thận trọng appear to + V đúng cấu trúc. Câu đầu khái quát hoá quá mức; tend to spending sai dạng động từ; are appear thừa động từ be.",
      },
      {
        type: "choice",
        q: "Working from home ___ improve employees' work–life balance, although it can also lead to isolation.",
        options: ["may", "is likely", "tends", "seems"],
        answer: 0,
        explain:
          "Modal may đi trực tiếp với động từ nguyên thể improve. Is likely, tends, seems đều cần to trước động từ (is likely to improve, tends to improve...), nên không điền được vào chỗ trống.",
      },
      {
        type: "choice",
        q: "Rising temperatures are ___ to cause more frequent floods in coastal areas.",
        options: ["possible", "may", "likely to", "likely"],
        answer: 3,
        explain:
          "Cấu trúc be likely to + V: are likely to cause. Likely to sẽ lặp to hai lần; possible không dùng với chủ ngữ là vật + to V; may không đứng sau are.",
      },
      {
        type: "choice",
        q: "___, the internet has widened the gap between rich and poor countries.",
        options: ["To some extents", "To some extent", "In some extent", "At some extent"],
        answer: 1,
        explain:
          "Cụm cố định là to some extent (extent ở dạng số ít, giới từ to). To some extents thêm -s sai; in/at some extent sai giới từ.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng ngữ pháp:",
        options: [
          "It is likely more people to work remotely in the future.",
          "More people likely to work remotely in the future.",
          "It is likely that more people will work remotely in the future.",
          "It likely that more people will work remotely in the future.",
        ],
        answer: 2,
        explain:
          "It is likely that + mệnh đề đầy đủ là đúng. Câu đầu trộn hai cấu trúc; câu thứ hai thiếu động từ are; câu cuối thiếu is.",
      },
      {
        type: "choice",
        q: "The figures ___ that the scheme has had little effect on unemployment.",
        options: ["are suggesting to", "suggest", "seem", "tend"],
        answer: 1,
        explain:
          "Suggest that + mệnh đề dùng để nói số liệu cho thấy điều gì. Seem và tend không đi với that theo cách này (phải là It seems that... hoặc seem to + V); are suggesting to sai cấu trúc.",
      },
      {
        type: "fill",
        q: "Children who read regularly ___ to perform better at school.",
        hint: "(tend) – chia ở thì hiện tại",
        answers: ["tend"],
        explain:
          "Chủ ngữ Children số nhiều nên dùng tend (không thêm -s). Tend to + V diễn tả xu hướng chung, mềm hơn so với always perform better.",
      },
      {
        type: "fill",
        q: "It is ___ that self-driving cars will become common within the next twenty years.",
        hint: "(possibility) – đổi sang tính từ",
        answers: ["possible"],
        explain:
          "Cấu trúc It is + tính từ + that: It is possible that... Danh từ possibility không đứng sau It is trong cấu trúc này.",
      },
      {
        type: "fill",
        q: "A significant ___ of graduates now work in jobs unrelated to their degree.",
        hint: "(tỉ lệ – danh từ bắt đầu bằng p)",
        answers: ["proportion", "percentage"],
        explain:
          "A significant proportion/percentage of thay cho all graduates, giúp nhận định chính xác và thận trọng hơn. Dùng part hay portion không phải cách diễn đạt chuẩn cho tỉ lệ người.",
      },
      {
        type: "fill",
        q: "The new policy appears ___ reduced traffic in the city centre.",
        hint: "(have) – hai từ",
        answers: ["to have"],
        explain:
          "Hành động giảm lưu lượng xe đã xảy ra, nên dùng động từ nguyên thể hoàn thành: appear to have + V3. Viết appears to reduced hay appears having reduced đều sai.",
      },
    ],
  },

  // 4. Đảo ngữ
  {
    id: "inversion",
    group: "advanced",
    band: "7.0",
    title: "Đảo ngữ",
    en: "Inversion",
    summary:
      "Đảo ngữ (inversion) đưa trạng từ phủ định hoặc giới hạn lên đầu câu rồi đảo trợ động từ lên trước chủ ngữ để nhấn mạnh. Một câu đảo ngữ đúng chỗ cho thấy khả năng kiểm soát cấu trúc phức; lạm dụng hoặc đảo sai sẽ phản tác dụng.",
    rules: [
      {
        title: "Not only ... but (also)",
        body: "Khi Not only đứng đầu câu, mệnh đề thứ nhất phải đảo trợ động từ (do/does/did, is/are, have/has, can...) lên trước chủ ngữ. Mệnh đề sau but giữ trật tự bình thường.",
        form: "Not only + trợ động từ + S + V, but + S + (also) + V",
        examples: [
          {
            en: "**Not only does** urbanisation increase pollution, **but it also** puts pressure on housing.",
            vi: "Đô thị hoá không chỉ làm tăng ô nhiễm mà còn gây áp lực lên nhà ở.",
          },
          {
            en: "**Not only is** public transport cheaper, **but it is also** better for the environment.",
            vi: "Giao thông công cộng không chỉ rẻ hơn mà còn tốt hơn cho môi trường.",
          },
          {
            en: "**Not only did** the scheme reduce costs, **but it also** improved staff morale.",
            vi: "Chương trình này không chỉ giảm chi phí mà còn nâng cao tinh thần của nhân viên.",
          },
        ],
      },
      {
        title: "Rarely, Seldom, Never, Little",
        body: "Các trạng từ mang nghĩa phủ định đứng đầu câu kéo theo đảo ngữ. Nếu câu gốc không có trợ động từ thì thêm do/does/did. Never (before) thường đi với thì hiện tại hoàn thành.",
        form: "Rarely/Seldom/Never + trợ động từ + S + V",
        examples: [
          {
            en: "**Rarely do** governments invest enough in mental health services.",
            vi: "Hiếm khi các chính phủ đầu tư thoả đáng cho dịch vụ chăm sóc sức khoẻ tâm thần.",
          },
          {
            en: "**Never before has** information been so easy to access.",
            vi: "Chưa bao giờ thông tin lại dễ tiếp cận đến thế.",
          },
          {
            en: "**Little do** many consumers realise how much plastic they throw away.",
            vi: "Nhiều người tiêu dùng hầu như không nhận ra họ thải ra bao nhiêu rác nhựa.",
          },
        ],
      },
      {
        title: "Hardly/Scarcely ... when; No sooner ... than",
        body: "Diễn tả hai sự việc xảy ra gần như liền nhau trong quá khứ. Mệnh đề đầu đảo ngữ với quá khứ hoàn thành; Hardly/Scarcely đi với when, còn No sooner đi với than.",
        form: "Hardly/Scarcely + had + S + V3 + when + S + V2   |   No sooner + had + S + V3 + than + S + V2",
        examples: [
          {
            en: "**No sooner had** the new law been introduced **than** companies began to look for loopholes.",
            vi: "Luật mới vừa được ban hành thì các công ty đã bắt đầu tìm kẽ hở.",
          },
          {
            en: "**Hardly had** the factory opened **when** residents started complaining about the noise.",
            vi: "Nhà máy vừa mới đi vào hoạt động thì cư dân đã bắt đầu phàn nàn về tiếng ồn.",
          },
        ],
      },
      {
        title: "Not until / Only when / Only by / Only after",
        body: "Phần đứng sau Not until, Only when, Only after là một mệnh đề hoặc cụm từ giữ trật tự bình thường; đảo ngữ xảy ra ở mệnh đề chính phía sau.",
        form: "Not until/Only when + mệnh đề thường, trợ động từ + S + V   |   Only by + V-ing, trợ động từ + S + V",
        examples: [
          {
            en: "**Not until** the late 1990s **did** most households own a computer.",
            vi: "Mãi đến cuối những năm 1990, phần lớn hộ gia đình mới có máy tính.",
          },
          {
            en: "**Only when** clean water is widely available **will** public health improve significantly.",
            vi: "Chỉ khi nước sạch được phổ cập thì sức khoẻ cộng đồng mới cải thiện đáng kể.",
          },
          {
            en: "**Only by** investing in renewable energy **can** countries meet their climate targets.",
            vi: "Chỉ bằng cách đầu tư vào năng lượng tái tạo, các quốc gia mới đạt được mục tiêu khí hậu.",
          },
        ],
      },
      {
        title: "Đảo ngữ câu điều kiện: Should, Were, Had",
        body: "Bỏ if và đưa should (loại 1), were (loại 2) hoặc had (loại 3) lên đầu câu; văn phong trang trọng. Với động từ thường ở loại 2 dùng Were + S + to V. Dạng phủ định không rút gọn: Had it not been for..., không viết Hadn't...",
        form: "Should + S + V, ...   |   Were + S + to V / Were + S + ..., S + would + V   |   Had + S + V3, S + would have + V3",
        examples: [
          {
            en: "**Should** the current trend **continue**, unemployment will rise further.",
            vi: "Nếu xu hướng hiện tại tiếp diễn, tỉ lệ thất nghiệp sẽ còn tăng.",
          },
          {
            en: "**Were** the government **to raise** taxes, consumer spending would fall.",
            vi: "Nếu chính phủ tăng thuế, chi tiêu của người tiêu dùng sẽ giảm.",
          },
          {
            en: "**Had** the city **invested** in flood defences earlier, the damage would have been far less severe.",
            vi: "Nếu thành phố đầu tư vào hệ thống chống lũ sớm hơn, thiệt hại đã ít nghiêm trọng hơn nhiều.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Một câu đảo ngữ chính xác, thường ở phần nhấn mạnh luận điểm hoặc kết bài, là đủ. Band 7 không bắt buộc phải có đảo ngữ; một câu đảo sai gây hại cho điểm Accuracy nhiều hơn là không dùng.",
        example:
          "Only by working together can governments tackle climate change effectively.",
      },
      {
        part: "Writing Task 2",
        tip: "Đảo ngữ điều kiện (Were... to, Should...) rất hợp khi đề xuất giải pháp và nêu hệ quả, giúp câu trang trọng mà không cần lặp if.",
        example:
          "Were these measures to be introduced, traffic congestion would fall considerably.",
      },
      {
        part: "Speaking",
        tip: "Trong Speaking, đảo ngữ dễ nghe gượng ép. Nếu dùng, chọn dạng phổ biến trong văn nói như Not only... hay Never have I...; ưu tiên sự trôi chảy hơn là cấu trúc cầu kỳ.",
        example: "Not only is it cheaper to live there, but it's also much quieter.",
      },
    ],
    mistakes: [
      {
        wrong: "Not only it is cheap, but it is also convenient.",
        right: "Not only is it cheap, but it is also convenient.",
        note: "Not only đứng đầu câu bắt buộc đảo trợ động từ is lên trước chủ ngữ it.",
      },
      {
        wrong: "Never I have seen such heavy traffic.",
        right: "Never have I seen such heavy traffic.",
        note: "Sau Never đứng đầu câu phải đảo have lên trước I, không giữ trật tự như tiếng Việt.",
      },
      {
        wrong: "Rarely students read newspapers nowadays.",
        right: "Rarely do students read newspapers nowadays.",
        note: "Câu không có trợ động từ thì phải mượn do/does/did để đảo ngữ.",
      },
      {
        wrong: "Not until did I move to Hanoi I realised how bad the pollution was.",
        right: "Not until I moved to Hanoi did I realise how bad the pollution was.",
        note: "Mệnh đề sau Not until giữ trật tự thường; đảo ngữ nằm ở mệnh đề chính phía sau.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Not only ___ air pollution, but it also wastes commuters' time.",
        options: [
          "traffic congestion causes",
          "does traffic congestion cause",
          "traffic congestion does cause",
          "causes traffic congestion",
        ],
        answer: 1,
        explain:
          "Not only đứng đầu câu cần đảo trợ động từ: does + S + V nguyên thể. Traffic congestion causes giữ trật tự thường nên sai; traffic congestion does cause có does nhưng chưa đảo.",
      },
      {
        type: "choice",
        q: "Rarely ___ such a dramatic fall in unemployment.",
        options: ["we have seen", "we saw", "seen we have", "have we seen"],
        answer: 3,
        explain:
          "Rarely đứng đầu câu kéo theo đảo ngữ: have + we + seen. We have seen là lỗi giữ trật tự thường, rất hay gặp ở người Việt.",
      },
      {
        type: "choice",
        q: "No sooner had the policy been announced ___ protests broke out.",
        options: ["than", "when", "then", "that"],
        answer: 0,
        explain:
          "No sooner luôn đi với than (vì sooner là dạng so sánh hơn). When chỉ đi với Hardly/Scarcely, nên dễ gây nhầm.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng ngữ pháp:",
        options: [
          "Not until the bridge was built people could travel easily between the two towns.",
          "Not until was the bridge built could people travel easily between the two towns.",
          "Not until the bridge was built could people travel easily between the two towns.",
          "Not until the bridge was built, people could travel easily between the two towns.",
        ],
        answer: 2,
        explain:
          "Mệnh đề sau Not until (the bridge was built) giữ trật tự thường, còn mệnh đề chính đảo: could people travel. Câu đầu và câu cuối quên đảo ở mệnh đề chính; câu thứ hai đảo nhầm chỗ.",
      },
      {
        type: "choice",
        q: "___ the government to invest more in public transport, fewer people would rely on cars.",
        options: ["If", "Had", "Should", "Were"],
        answer: 3,
        explain:
          "Đảo ngữ điều kiện loại 2 với động từ thường: Were + S + to V, đi với would ở mệnh đề chính. If không đi với to invest; Had dùng cho loại 3 (Had + S + V3).",
      },
      {
        type: "choice",
        q: "Only by reducing meat consumption ___ significantly cut greenhouse gas emissions.",
        options: ["can we", "we can", "we will", "do we can"],
        answer: 0,
        explain:
          "Only by + V-ing đứng đầu câu thì mệnh đề chính phải đảo: can we cut. We can và we will giữ trật tự thường; do we can thừa trợ động từ do.",
      },
      {
        type: "fill",
        q: "Never before ___ so many people had access to higher education.",
        hint: "(have) – chia đúng thì và đảo ngữ",
        answers: ["have"],
        explain:
          "Never before đi với hiện tại hoàn thành và đảo ngữ; chủ ngữ so many people số nhiều nên dùng have (Never before have so many people had...). Has sai về sự hoà hợp chủ ngữ – động từ.",
      },
      {
        type: "fill",
        q: "Hardly had the new tax been introduced ___ prices started to rise.",
        hint: "(một liên từ)",
        answers: ["when", "before"],
        explain:
          "Hardly ... when (hoặc before) diễn tả hai việc nối tiếp nhau ngay lập tức. Than chỉ dùng với No sooner, nên không điền than ở đây.",
      },
      {
        type: "fill",
        q: "___ you need further information, please contact the admissions office.",
        hint: "(đảo ngữ điều kiện thay cho If)",
        answers: ["should"],
        explain:
          "Should + S + V thay cho If + S + V (điều kiện loại 1), văn phong trang trọng. Were và Had không hợp vì mệnh đề chính là câu mệnh lệnh ở hiện tại.",
      },
      {
        type: "fill",
        q: "___ the city invested in flood defences earlier, the damage would have been much less severe.",
        hint: "(đảo ngữ thay cho If + quá khứ hoàn thành)",
        answers: ["had"],
        explain:
          "Điều kiện loại 3 (giả định trái quá khứ, mệnh đề chính would have been) đảo thành Had + S + V3. Were dùng cho loại 2 nên không phù hợp.",
      },
    ],
  },

  // 5. Câu chẻ
  {
    id: "cleft-sentences",
    group: "advanced",
    band: "7.0",
    title: "Câu chẻ",
    en: "Cleft Sentences",
    summary:
      "Câu chẻ (cleft sentence) tách một câu thành hai vế để làm nổi bật thông tin then chốt, giúp lập luận có trọng tâm và liên kết chặt hơn. Đây là cấu trúc rất tự nhiên trong cả Writing lẫn Speaking nếu dùng đúng mức.",
    rules: [
      {
        title: "Câu chẻ với It (it-cleft)",
        body: "Đặt phần cần nhấn mạnh giữa It is/was và that/who. Dùng who cho người, that cho cả người và vật; động từ trong mệnh đề that/who chia theo phần được nhấn mạnh.",
        form: "It is/was + phần nhấn mạnh + that/who + phần còn lại",
        examples: [
          {
            en: "**It is** young people **who** suffer most from rising housing costs.",
            vi: "Chính người trẻ là những người chịu ảnh hưởng nặng nề nhất khi giá nhà tăng.",
          },
          {
            en: "**It was** the invention of the smartphone **that** transformed how we access information.",
            vi: "Chính sự ra đời của điện thoại thông minh đã thay đổi cách chúng ta tiếp cận thông tin.",
          },
          {
            en: "**It is** not the cost but the lack of time **that** stops many adults from exercising.",
            vi: "Không phải chi phí mà chính việc thiếu thời gian khiến nhiều người trưởng thành không tập thể dục.",
          },
        ],
      },
      {
        title: "Câu chẻ với What (what-cleft)",
        body: "Mệnh đề What + S + V đóng vai trò chủ ngữ, đẩy thông tin quan trọng về cuối câu sau is/was. Mệnh đề what được coi là số ít nên thường dùng is/was. Khi phần sau là hành động với do, có thể dùng động từ nguyên thể không to.",
        form: "What + S + V + is/was + N / (to) V / that-clause",
        examples: [
          {
            en: "**What worries many experts is** the growing gap between rich and poor.",
            vi: "Điều khiến nhiều chuyên gia lo ngại là khoảng cách giàu nghèo ngày càng lớn.",
          },
          {
            en: "**What schools need is** more qualified teachers, not more technology.",
            vi: "Điều các trường học cần là thêm giáo viên có trình độ, chứ không phải thêm công nghệ.",
          },
          {
            en: "**What the government should do is** invest in affordable housing.",
            vi: "Điều chính phủ nên làm là đầu tư vào nhà ở giá rẻ.",
          },
        ],
      },
      {
        title: "The reason why ... is that ...",
        body: "Dùng để nhấn mạnh nguyên nhân. Trong văn viết trang trọng, dùng is that; cách nói is because phổ biến trong khẩu ngữ nhưng bị coi là thừa ý. Các dạng tương tự: The main problem is that..., The thing is that...",
        form: "The reason (why) + mệnh đề + is that + mệnh đề",
        examples: [
          {
            en: "**The reason why** many graduates move to big cities **is that** salaries there are higher.",
            vi: "Lý do nhiều sinh viên tốt nghiệp chuyển đến thành phố lớn là vì lương ở đó cao hơn.",
          },
          {
            en: "**The main problem is that** many rural areas still lack reliable internet access.",
            vi: "Vấn đề chính là nhiều vùng nông thôn vẫn chưa có Internet ổn định.",
          },
        ],
      },
      {
        title: "All (that) ... is/was ...",
        body: "Nhấn mạnh rằng chỉ cần một điều duy nhất, mang nghĩa \"tất cả những gì... chỉ là\". Động từ chính dùng is/was.",
        form: "All (that) + S + V + is/was + N / (to) V",
        examples: [
          {
            en: "**All (that)** many young people **want is** a stable job and an affordable home.",
            vi: "Tất cả những gì nhiều người trẻ mong muốn chỉ là một công việc ổn định và một căn nhà vừa túi tiền.",
          },
          {
            en: "**All we need to do is** change a few daily habits.",
            vi: "Tất cả những gì chúng ta cần làm chỉ là thay đổi vài thói quen hằng ngày.",
          },
        ],
      },
      {
        title: "Câu chẻ để đối lập và liên kết ý",
        body: "Câu chẻ rất hiệu quả khi muốn bác bỏ một quan điểm và nhấn mạnh quan điểm khác (not X but Y, rather than), tạo mạch lạc giữa các câu trong đoạn văn.",
        examples: [
          {
            en: "Many people blame social media. However, **it is** poor sleep habits **that** have the greatest impact on teenagers' health.",
            vi: "Nhiều người đổ lỗi cho mạng xã hội. Tuy nhiên, chính thói quen ngủ kém mới ảnh hưởng lớn nhất đến sức khoẻ thanh thiếu niên.",
          },
          {
            en: "**What** makes this policy effective **is not** its cost **but** its simplicity.",
            vi: "Điều khiến chính sách này hiệu quả không phải là chi phí mà là sự đơn giản của nó.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Dùng it-cleft hoặc what-cleft để nhấn mạnh luận điểm chính hay phản bác ý kiến đối lập. Một đến hai câu chẻ mỗi bài là đủ; dùng dày đặc sẽ khiến văn phong lặp và gượng.",
        example:
          "It is the government, rather than individuals, that should take the lead in reducing carbon emissions.",
      },
      {
        part: "Speaking",
        tip: "What-cleft rất tự nhiên trong văn nói, đặc biệt ở Part 2 và Part 3 khi giải thích điều bạn thích hoặc lo ngại. Đây là cách dễ nhất để thể hiện cấu trúc phức mà vẫn trôi chảy.",
        example: "What I really love about my hometown is the street food.",
      },
      {
        part: "Writing",
        tip: "Khi giải thích nguyên nhân trong bài viết, dùng The reason why... is that... thay vì is because để giữ văn phong trang trọng và chính xác.",
        example:
          "The reason why many people avoid public transport is that it is often unreliable.",
      },
    ],
    mistakes: [
      {
        wrong: "It is the government that should to act.",
        right: "It is the government that should act.",
        note: "Sau modal should là động từ nguyên thể không to, kể cả trong câu chẻ.",
      },
      {
        wrong: "What makes me worried it is the cost of living.",
        right: "What worries me is the cost of living.",
        note: "Mệnh đề What đã là chủ ngữ, không thêm it như khi dịch từng chữ \"điều... đó là\".",
      },
      {
        wrong: "The reason why I chose this course is because it is practical.",
        right: "The reason why I chose this course is that it is practical.",
        note: "Reason đã mang nghĩa nguyên nhân nên because bị thừa; văn viết trang trọng dùng is that.",
      },
      {
        wrong: "It is young people that is most affected by unemployment.",
        right: "It is young people who are most affected by unemployment.",
        note: "Động từ sau that/who chia theo phần được nhấn mạnh (young people số nhiều → are).",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "It was in 2010 ___ the law on plastic bags was passed.",
        options: ["when", "which", "that", "what"],
        answer: 2,
        explain:
          "Trong it-cleft, phần nhấn mạnh là cụm giới từ chỉ thời gian (in 2010) thì vẫn dùng that. When dễ gây nhầm vì có yếu tố thời gian, nhưng không phải dạng chuẩn sau cụm in 2010.",
      },
      {
        type: "choice",
        q: "___ many parents worry about is the amount of time their children spend online.",
        options: ["What", "That", "Which", "It"],
        answer: 0,
        explain:
          "Cần mệnh đề What làm chủ ngữ (= the thing that). That và Which không thể tự làm chủ ngữ theo cách này; It sẽ tạo ra câu thiếu that/who.",
      },
      {
        type: "choice",
        q: "It is older workers ___ find it hardest to adapt to new technology.",
        options: ["which", "what", "whose", "who"],
        answer: 3,
        explain:
          "Phần nhấn mạnh là người (older workers) nên dùng who (hoặc that). Which dùng cho vật; what không dùng trong it-cleft; whose chỉ sở hữu.",
      },
      {
        type: "choice",
        q: "Chọn câu đúng ngữ pháp:",
        options: [
          "The reason why many people prefer cars are that buses are unreliable.",
          "The reason why many people prefer cars is that buses are unreliable.",
          "The reason why do many people prefer cars is that buses are unreliable.",
          "The reason many people prefer cars it is that buses are unreliable.",
        ],
        answer: 1,
        explain:
          "Chủ ngữ là The reason (số ít) nên dùng is, và mệnh đề sau why giữ trật tự thường. Câu đầu chia are theo cars là sai; câu thứ ba đảo trợ động từ do như câu hỏi; câu cuối thừa it.",
      },
      {
        type: "choice",
        q: "All the city ___ is a more efficient public transport system.",
        options: ["needs", "need", "needing", "is needed"],
        answer: 0,
        explain:
          "All (that) the city needs is...: chủ ngữ the city số ít nên needs. Need thiếu -s; needing và is needed sai cấu trúc.",
      },
      {
        type: "choice",
        q: "Chọn câu chẻ diễn đạt đúng ý 'chính sự thiếu nhà ở giá rẻ, chứ không phải lương thấp, khiến người trẻ rời thành phố':",
        options: [
          "It is low salaries, not the lack of affordable housing, that drive young people out of the city.",
          "What drives young people out of the city are low salaries.",
          "It is the lack of affordable housing, not low salaries, that drives young people out of the city.",
          "It is the lack of affordable housing, not low salaries, that drive young people out of the city.",
        ],
        answer: 2,
        explain:
          "Phần nhấn mạnh là the lack of affordable housing (danh từ chính lack số ít) nên động từ là drives. Câu cuối sai sự hoà hợp (drive); hai câu đầu nhấn mạnh sai ý (low salaries).",
      },
      {
        type: "fill",
        q: "What concerns environmentalists most ___ the loss of tropical rainforests.",
        hint: "(be) – thì hiện tại",
        answers: ["is"],
        explain:
          "Mệnh đề What... làm chủ ngữ được coi là số ít, nên dùng is. Are là lỗi chia theo environmentalists.",
      },
      {
        type: "fill",
        q: "It was not until 2015 ___ the city opened its first metro line.",
        hint: "(một từ nối)",
        answers: ["that"],
        explain:
          "Cấu trúc câu chẻ It was not until + thời điểm + that + mệnh đề. When hoặc then không dùng ở vị trí này.",
      },
      {
        type: "fill",
        q: "The main reason ___ young people leave rural areas is that there are few job opportunities.",
        hint: "(một từ, thường đi sau reason)",
        answers: ["why", "that"],
        explain:
          "The reason why (hoặc that) + mệnh đề giới thiệu nguyên nhân. Because không đứng được ở đây vì sẽ tạo thành reason because, lặp nghĩa.",
      },
      {
        type: "fill",
        q: "What the government should ___ is invest more in vocational training.",
        hint: "(do)",
        answers: ["do"],
        explain:
          "Cấu trúc What + S + do + is + (to) V nhấn mạnh hành động. Sau should là động từ nguyên thể do, không dùng does hay doing.",
      },
    ],
  },
];
