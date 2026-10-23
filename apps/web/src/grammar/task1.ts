import type { GrammarUnit } from "./types";

export const task1: GrammarUnit[] = [
  // ---------------------------------------------------------------------------
  // 1. So sánh
  // ---------------------------------------------------------------------------
  {
    id: "comparisons",
    group: "task1",
    band: "6.0",
    title: "So sánh",
    en: "Comparisons",
    summary:
      "Bài này hệ thống các cấu trúc so sánh hơn, so sánh nhất, so sánh ngang bằng và so sánh bội số để đối chiếu số liệu chính xác. Writing Task 1 gần như luôn yêu cầu so sánh, nên dùng đúng và đa dạng các cấu trúc này giúp nâng điểm Grammatical Range and Accuracy.",
    rules: [
      {
        title: "So sánh hơn và so sánh nhất (comparative & superlative)",
        body: "Tính từ ngắn (một âm tiết, hoặc hai âm tiết tận cùng -y) thêm -er / -est; tính từ dài dùng more / the most. Tuyệt đối không dùng cả hai cách cùng lúc, và so sánh nhất luôn có the đứng trước.",
        form: "adj-er / more + adj + than …  |  the + adj-est / the most + adj",
        examples: [
          {
            en: "Sales of electric cars were **higher** in 2020 **than** in 2015.",
            vi: "Doanh số xe điện năm 2020 cao hơn năm 2015.",
          },
          {
            en: "Norway had **the highest** proportion of electric cars among the five countries.",
            vi: "Na Uy có tỉ lệ xe điện cao nhất trong năm quốc gia.",
          },
          {
            en: "Solar power became **more popular than** wind power after 2018.",
            vi: "Điện mặt trời trở nên phổ biến hơn điện gió sau năm 2018.",
          },
        ],
      },
      {
        title: "So sánh về lượng: more / less / fewer",
        body: "More dùng cho cả danh từ đếm được và không đếm được. Fewer đi với danh từ đếm được số nhiều (cars, users), còn less đi với danh từ không đếm được (energy, water). Trong văn viết học thuật, giám khảo đánh giá cao việc phân biệt fewer và less.",
        form: "more / fewer + N đếm được số nhiều  |  more / less + N không đếm được",
        examples: [
          {
            en: "In 2000, Vietnam had **fewer internet users** than Thailand.",
            vi: "Năm 2000, Việt Nam có ít người dùng Internet hơn Thái Lan.",
          },
          {
            en: "Households in Mexico consumed **less energy** for heating than those in Canada.",
            vi: "Các hộ gia đình ở Mexico tiêu thụ ít năng lượng để sưởi ấm hơn các hộ ở Canada.",
          },
          {
            en: "By 2020, **more people** in India used the internet **than** in the US.",
            vi: "Đến năm 2020, số người dùng Internet ở Ấn Độ đã nhiều hơn ở Mỹ.",
          },
        ],
      },
      {
        title: "So sánh ngang bằng và bội số (as … as, twice as … as, double, half)",
        body: "As + adj/adv + as diễn tả hai mức bằng nhau; not as/so … as nghĩa là kém hơn. Muốn nói gấp bao nhiêu lần, đặt twice / three times trước as … as; double và half đứng ngay trước danh từ hoặc that/those, không đi với than.",
        form: "(not) as + adj + as  |  twice / three times as + adj + as  |  double / half + (that of) N",
        examples: [
          {
            en: "Spending on rent was **not as high as** spending on food.",
            vi: "Chi tiêu cho tiền thuê nhà không cao bằng chi tiêu cho thực phẩm.",
          },
          {
            en: "Canadian households used **twice as much energy as** Mexican households.",
            vi: "Các hộ gia đình Canada dùng lượng năng lượng gấp đôi hộ gia đình Mexico.",
          },
          {
            en: "By 2020, coal consumption was only **half that** of 1990.",
            vi: "Đến năm 2020, lượng than tiêu thụ chỉ còn bằng một nửa năm 1990.",
          },
        ],
      },
      {
        title: "Mức độ chênh lệch và cấu trúc càng … càng (modifiers & the … the …)",
        body: "Đặt slightly, a little (chênh ít) hoặc much, far, considerably, significantly (chênh nhiều) trước so sánh hơn; by far đi với so sánh nhất. Cấu trúc the + so sánh hơn, the + so sánh hơn diễn tả hai đại lượng thay đổi cùng nhau.",
        form: "slightly / much / far + comparative  |  by far + the superlative  |  The + comparative …, the + comparative …",
        examples: [
          {
            en: "Internet use in Korea was **considerably higher** than in Brazil.",
            vi: "Tỉ lệ dùng Internet ở Hàn Quốc cao hơn đáng kể so với Brazil.",
          },
          {
            en: "Electricity was **by far the largest** source of household energy.",
            vi: "Điện là nguồn năng lượng hộ gia đình lớn nhất, bỏ xa các nguồn khác.",
          },
          {
            en: "**The higher** the price of petrol, **the more** people chose public transport.",
            vi: "Giá xăng càng cao thì càng nhiều người chọn phương tiện công cộng.",
          },
        ],
      },
      {
        title: "Đối chiếu hai số liệu bằng while / whereas",
        body: "While và whereas nối hai mệnh đề trái ngược nhau trong cùng một câu, giúp so sánh hai đối tượng mà không phải viết hai câu rời. Thường đặt dấu phẩy trước whereas/while khi nó đứng giữa câu.",
        form: "Clause 1, whereas / while + clause 2  |  While + clause 1, clause 2",
        examples: [
          {
            en: "In 2020, 96% of Koreans used the internet, **whereas** only 43% of Indians did.",
            vi: "Năm 2020, 96% người Hàn Quốc dùng Internet, trong khi chỉ 43% người Ấn Độ dùng.",
          },
          {
            en: "**While** sales of petrol cars fell steadily, those of electric cars rose sharply.",
            vi: "Trong khi doanh số xe xăng giảm đều thì doanh số xe điện tăng mạnh.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip: "Câu tổng quan (overview) nên nêu điểm nổi bật nhất bằng so sánh nhất kèm by far và một vế đối lập với whereas/while. Đây là câu giám khảo đọc đầu tiên để chấm Task Achievement và cũng thể hiện cấu trúc phức.",
        example:
          "Overall, Norway had by far the highest proportion of electric cars, whereas Italy consistently had the lowest.",
      },
      {
        part: "Writing Task 1",
        tip: "Để tránh so sánh khập khiễng và lặp từ, dùng that of / those of (hoặc the figure for) thay cho danh từ đã nhắc. Kết hợp với bội số để có câu vừa chính xác vừa đa dạng.",
        example:
          "The number of internet users in Thailand was almost three times as high as that in Laos.",
      },
      {
        part: "Speaking",
        tip: "Khi được hỏi về thay đổi theo thời gian (Part 3), dùng much/far + so sánh hơn hoặc cấu trúc the … the … để câu trả lời tự nhiên và có chiều sâu hơn so với chỉ nói 'more'.",
        example:
          "Hanoi is far busier than it used to be, and the bigger the city gets, the harder it is to find green space.",
      },
    ],
    mistakes: [
      {
        wrong: "Sales in 2020 were more higher than in 2015.",
        right: "Sales in 2020 were much higher than in 2015.",
        note: "Higher đã là so sánh hơn nên không thêm more; muốn nhấn mạnh thì dùng much/far.",
      },
      {
        wrong: "There were less cars on the roads in 2000.",
        right: "There were fewer cars on the roads in 2000.",
        note: "Cars là danh từ đếm được số nhiều nên phải dùng fewer, không dùng less.",
      },
      {
        wrong: "Energy use in Canada was double than in Mexico.",
        right: "Energy use in Canada was double that in Mexico.",
        note: "Double và half không đi với than; dùng double that / twice as high as.",
      },
      {
        wrong: "The price of rice in Vietnam was lower than Thailand.",
        right: "The price of rice in Vietnam was lower than that in Thailand.",
        note: "Phải so giá với giá (that = the price), không so giá với một quốc gia.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "Sales of electric cars in 2020 were ___ than in 2015.",
        options: ["more high", "higher", "more higher", "highest"],
        answer: 1,
        explain:
          "High là tính từ ngắn nên so sánh hơn là higher. 'More higher' sai vì dùng hai lần dấu hiệu so sánh; 'more high' sai vì tính từ ngắn không đi với more.",
      },
      {
        type: "choice",
        q: "Of all the countries shown, Norway had ___ proportion of electric cars.",
        options: ["the highest", "higher", "the most high", "a highest"],
        answer: 0,
        explain:
          "Of all the countries cho thấy so sánh trong một nhóm nên dùng so sánh nhất the highest. 'The most high' sai vì high là tính từ ngắn; 'a highest' sai vì so sánh nhất đi với the.",
      },
      {
        type: "choice",
        q: "In 2010, Vietnam had ___ internet users than Thailand.",
        options: ["less", "lesser", "littler", "fewer"],
        answer: 3,
        explain:
          "Users là danh từ đếm được số nhiều nên dùng fewer. 'Less' chỉ đi với danh từ không đếm được (less energy), dù văn nói đôi khi dùng lẫn, bài viết học thuật cần fewer.",
      },
      {
        type: "choice",
        q: "Households in Canada used ___ energy as those in Mexico.",
        options: ["twice as many", "two times more much", "twice as much", "double as much"],
        answer: 2,
        explain:
          "Energy không đếm được nên dùng much, và bội số đặt trước as … as: twice as much … as. 'Twice as many' sai vì many dùng cho danh từ đếm được; double không đi với as … as.",
      },
      {
        type: "choice",
        q: "By 2020, coal consumption had fallen to only ___ that in 1990.",
        options: ["half", "half as", "a half than", "half of than"],
        answer: 0,
        explain:
          "Half đứng thẳng trước that (= the consumption): half that in 1990. Các phương án có than sai vì half/double không đi với than; 'half as' thiếu vế as … as hoàn chỉnh.",
      },
      {
        type: "choice",
        q: "The ___ the price of petrol, the more people chose public transport.",
        options: ["high", "highest", "higher", "more high"],
        answer: 2,
        explain:
          "Cấu trúc càng … càng là the + so sánh hơn, the + so sánh hơn, nên cần higher. 'Highest' là so sánh nhất, không dùng trong cấu trúc này.",
      },
      {
        type: "fill",
        q: "Spending on rent was not ___ high as spending on food.",
        hint: "(so sánh không bằng)",
        answers: ["as", "so"],
        explain:
          "Not as/so + adj + as diễn tả mức kém hơn. Không dùng 'than' ở đây vì vế sau đã có as.",
      },
      {
        type: "fill",
        q: "Germany produced ___ electricity from solar power than France in 2020.",
        hint: "(much → so sánh hơn)",
        answers: ["more"],
        explain:
          "So sánh hơn của much là more, đi được với danh từ không đếm được electricity. Không viết 'much more' trừ khi muốn nhấn mạnh mức chênh lệch.",
      },
      {
        type: "fill",
        q: "Japan had the ___ number of internet users of the three countries in 2000.",
        hint: "(large → so sánh nhất)",
        answers: ["largest"],
        explain:
          "Number đi với large/small chứ không đi với many/much; so sánh nhất của large là largest. Có 'of the three countries' nên phải là so sánh nhất, không phải larger.",
      },
      {
        type: "fill",
        q: "In 2020, 96% of Koreans used the internet, ___ only 43% of Indians did.",
        hint: "(liên từ đối lập, bắt đầu bằng w)",
        answers: ["whereas", "while", "whilst"],
        explain:
          "Whereas/while nối hai mệnh đề tương phản để đối chiếu song song hai số liệu. 'Although' dễ gây nhầm nhưng nó diễn tả nhượng bộ (dù… nhưng), không phải đối chiếu hai đối tượng.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 2. Mô tả xu hướng
  // ---------------------------------------------------------------------------
  {
    id: "describing-trends",
    group: "task1",
    band: "6.0",
    title: "Mô tả xu hướng",
    en: "Describing Trends",
    summary:
      "Bài này dạy cách mô tả tăng, giảm, dao động và ổn định bằng hai mẫu câu (động từ + trạng từ và tính từ + danh từ) cùng các giới từ đi kèm. Đây là kỹ năng cốt lõi của mọi biểu đồ đường và biểu đồ cột có mốc thời gian trong Writing Task 1.",
    rules: [
      {
        title: "Động từ + trạng từ và tính từ + danh từ (verb + adverb / adjective + noun)",
        body: "Có thể diễn đạt cùng một ý theo hai cách: động từ kèm trạng từ (rose sharply) hoặc danh từ kèm tính từ (a sharp rise in). Trạng từ bổ nghĩa cho động từ, tính từ bổ nghĩa cho danh từ; xen kẽ hai mẫu giúp bài không lặp cấu trúc.",
        form: "N + rose / fell + adv  |  There was + a/an + adj + rise / fall + in + N",
        examples: [
          {
            en: "Sales of electric cars **rose sharply** between 2018 and 2020.",
            vi: "Doanh số xe điện tăng mạnh từ năm 2018 đến năm 2020.",
          },
          {
            en: "There was **a sharp rise in** sales of electric cars between 2018 and 2020.",
            vi: "Doanh số xe điện có một mức tăng mạnh trong giai đoạn 2018–2020.",
          },
          {
            en: "Household gas consumption **declined gradually** over the period.",
            vi: "Lượng khí đốt hộ gia đình tiêu thụ giảm dần trong suốt giai đoạn.",
          },
        ],
      },
      {
        title: "Giới từ đi kèm xu hướng (by, to, of, at, from … to)",
        body: "By chỉ mức chênh lệch, to chỉ điểm đến, from … to chỉ điểm đầu và điểm cuối. Sau danh từ rise/fall, of chỉ mức thay đổi còn in chỉ đối tượng thay đổi; stood at, peaked at, hit a low of dùng để nêu một giá trị cụ thể.",
        form: "rise BY 10% / rise TO 50% / rise FROM 40% TO 50%  |  a rise OF 10% IN N  |  stand / peak AT + số",
        examples: [
          {
            en: "The number of internet users in Brazil rose **by** 20 million **to** 150 million.",
            vi: "Số người dùng Internet ở Brazil tăng thêm 20 triệu, lên 150 triệu.",
          },
          {
            en: "There was a rise **of** 10% **in** the price of electricity.",
            vi: "Giá điện tăng 10%.",
          },
          {
            en: "Unemployment **stood at** 5% in 2005 and **peaked at** 12% in 2009.",
            vi: "Tỉ lệ thất nghiệp ở mức 5% năm 2005 và đạt đỉnh 12% năm 2009.",
          },
        ],
      },
      {
        title: "Lấy thời gian làm chủ ngữ: saw / experienced / witnessed",
        body: "Thay vì luôn bắt đầu bằng đối tượng, có thể đặt mốc thời gian làm chủ ngữ với saw, experienced hoặc witnessed. Cách này giúp đa dạng cấu trúc câu, nhưng động từ phải đi với danh từ (a rise, a drop), không đi với động từ.",
        form: "Year / Period + saw / experienced + a/an + adj + N + in + đối tượng",
        examples: [
          {
            en: "**2008 saw a dramatic fall in** car sales across Europe.",
            vi: "Năm 2008 chứng kiến doanh số ô tô giảm mạnh trên toàn châu Âu.",
          },
          {
            en: "**The following decade experienced a steady increase in** solar energy use.",
            vi: "Thập kỷ tiếp theo ghi nhận lượng điện mặt trời sử dụng tăng đều.",
          },
        ],
      },
      {
        title: "Dao động, chững lại và ổn định (fluctuate, level off, remain stable)",
        body: "Không phải biểu đồ nào cũng chỉ tăng hoặc giảm. Fluctuate là lên xuống thất thường; level off / plateau là chững lại sau khi tăng hoặc giảm; remain stable / stay constant là gần như không đổi; hit a low / reach a peak là chạm đáy / chạm đỉnh. Lưu ý rise là nội động từ nên không có dạng bị động.",
        form: "N + fluctuated between X and Y  |  N + levelled off at X  |  N + remained stable at X",
        examples: [
          {
            en: "The price of oil **fluctuated between** $40 **and** $60 a barrel.",
            vi: "Giá dầu dao động trong khoảng 40 đến 60 đô la một thùng.",
          },
          {
            en: "After 2015, the figure **levelled off at** around 30%.",
            vi: "Sau năm 2015, số liệu chững lại ở mức khoảng 30%.",
          },
          {
            en: "Coal consumption **hit a low of** 2 million tonnes in 2019 before **remaining stable**.",
            vi: "Lượng than tiêu thụ chạm đáy 2 triệu tấn vào năm 2019 rồi giữ ổn định.",
          },
        ],
      },
      {
        title: "Chọn thì cho đúng mốc thời gian (tense choice)",
        body: "Số liệu đã qua dùng quá khứ đơn; câu giới thiệu biểu đồ dùng hiện tại đơn (The graph shows). Với số liệu dự báo, dùng is expected / projected / predicted to + V, hoặc will have + V3 khi nói đến một mốc tương lai cụ thể.",
        form: "Past: rose / fell  |  Future: is expected to + V  |  By + năm tương lai: will have + V3",
        examples: [
          {
            en: "The line graph **shows** household energy use in the UK from 1990 to 2030.",
            vi: "Biểu đồ đường thể hiện lượng năng lượng hộ gia đình ở Anh từ năm 1990 đến năm 2030.",
          },
          {
            en: "Solar energy use **is projected to double** between 2025 and 2030.",
            vi: "Lượng điện mặt trời sử dụng được dự báo sẽ tăng gấp đôi từ năm 2025 đến năm 2030.",
          },
          {
            en: "By 2040, the number of electric cars **will have overtaken** that of petrol cars.",
            vi: "Đến năm 2040, số lượng xe điện sẽ vượt số lượng xe xăng.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip: "Trong mỗi đoạn thân bài, xen kẽ ít nhất một câu động từ + trạng từ và một câu tính từ + danh từ (hoặc mốc thời gian + saw). Giám khảo chấm range dựa trên sự đa dạng cấu trúc, không chỉ từ vựng.",
        example:
          "Internet use in India rose steadily until 2010, after which the country saw a dramatic increase to 43% in 2020.",
      },
      {
        part: "Writing Task 1",
        tip: "Câu tổng quan (overview) mô tả xu hướng chung, không đưa số liệu cụ thể. Dùng động từ khái quát kèm while để gom hai xu hướng ngược chiều vào một câu.",
        example:
          "Overall, sales of electric cars increased significantly over the period, while those of petrol cars declined.",
      },
      {
        part: "Writing Task 1",
        tip: "Với biểu đồ có số liệu dự báo, đổi thì đúng ngay tại mốc hiện tại và dùng is expected / projected to để thể hiện bạn hiểu đó là dự đoán chứ không phải số liệu thật.",
        example:
          "The figure is expected to reach 60% by 2030, having stood at just 25% in 2015.",
      },
    ],
    mistakes: [
      {
        wrong: "The sales increased 10% in 2019.",
        right: "Sales increased by 10% in 2019.",
        note: "Thiếu giới từ by khi nêu mức chênh lệch; tiếng Việt nói 'tăng 10%' nên người học hay bỏ by.",
      },
      {
        wrong: "The price of electricity was risen sharply.",
        right: "The price of electricity rose sharply.",
        note: "Rise là nội động từ nên không có bị động; raise mới là ngoại động từ (the government raised prices).",
      },
      {
        wrong: "There was a significantly increase in tourism.",
        right: "There was a significant increase in tourism.",
        note: "Increase ở đây là danh từ nên phải dùng tính từ significant, không dùng trạng từ.",
      },
      {
        wrong: "The number of visitors peaked in 2 million in 2015.",
        right: "The number of visitors peaked at 2 million in 2015.",
        note: "Peak đi với at khi nêu giá trị; in chỉ dùng cho mốc năm.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "The number of tourists ___ by 15% between 2010 and 2015.",
        options: ["rose", "raised", "was risen", "rised"],
        answer: 0,
        explain:
          "Rise là nội động từ, quá khứ bất quy tắc là rose. 'Raised' cần tân ngữ (raise something); 'was risen' sai vì rise không có bị động; 'rised' không tồn tại.",
      },
      {
        type: "choice",
        q: "There was a ___ in the sales of electric cars in 2018.",
        options: ["dramatically increase", "dramatic increase", "dramatic increased", "dramatically increased"],
        answer: 1,
        explain:
          "Sau There was a cần cụm danh từ: tính từ dramatic + danh từ increase. 'Dramatically increase' sai vì trạng từ không bổ nghĩa cho danh từ.",
      },
      {
        type: "choice",
        q: "Unemployment peaked ___ 12% in 2009.",
        options: ["in", "on", "at", "by"],
        answer: 2,
        explain:
          "Peak at + giá trị là cụm cố định. 'By' chỉ mức chênh lệch nên sai nghĩa; 'in' dùng cho mốc năm (in 2009), không cho giá trị.",
      },
      {
        type: "choice",
        q: "Household energy use rose ___ 300 kWh in 2005 ___ 450 kWh in 2015.",
        options: ["at / to", "from / to", "by / at", "from / by"],
        answer: 1,
        explain:
          "From … to nêu điểm đầu và điểm cuối. 'From / by' sai vì 450 kWh là giá trị cuối chứ không phải mức tăng (mức tăng là 150 kWh).",
      },
      {
        type: "choice",
        q: "By 2030, the number of internet users in India ___ to reach 900 million.",
        options: ["is projected", "projects", "projected", "is projecting"],
        answer: 0,
        explain:
          "Số liệu dự báo dùng bị động be projected to + V. 'Projects' và 'is projecting' sai vì con số không tự dự báo; 'projected' thiếu be.",
      },
      {
        type: "choice",
        q: "After 2015, the price of oil ___, staying at around $50 a barrel.",
        options: ["fluctuated wildly", "levelled up", "was levelled off", "levelled off"],
        answer: 3,
        explain:
          "Level off nghĩa là chững lại, khớp với 'staying at around $50'. 'Fluctuated wildly' mâu thuẫn với ý giữ ổn định; level off là nội động từ nên không dùng bị động.",
      },
      {
        type: "fill",
        q: "The proportion of people working from home rose ___ 5% to 20% over the period.",
        hint: "(giới từ chỉ điểm bắt đầu)",
        answers: ["from"],
        explain:
          "Có to 20% ở sau nên cần from để nêu điểm đầu: from 5% to 20%. Không dùng 'by' vì 5% không phải mức tăng (mức tăng là 15 điểm phần trăm).",
      },
      {
        type: "fill",
        q: "2008 ___ a sharp fall in car sales.",
        hint: "(see, quá khứ)",
        answers: ["saw"],
        explain:
          "Khi mốc thời gian làm chủ ngữ, dùng saw + cụm danh từ. Năm 2008 đã qua nên dùng quá khứ saw, không dùng sees.",
      },
      {
        type: "fill",
        q: "Coal consumption declined ___ throughout the period.",
        hint: "(steady)",
        answers: ["steadily"],
        explain:
          "Bổ nghĩa cho động từ declined phải là trạng từ steadily. 'Steady' là tính từ, chỉ dùng trước danh từ (a steady decline).",
      },
      {
        type: "fill",
        q: "There was a rise ___ 10% in the number of students.",
        hint: "(giới từ sau danh từ rise khi nêu mức tăng)",
        answers: ["of"],
        explain:
          "Danh từ rise + of + mức thay đổi, + in + đối tượng. 'By' chỉ dùng sau động từ (rose by 10%), không dùng sau danh từ.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 3. Số liệu & tỉ lệ
  // ---------------------------------------------------------------------------
  {
    id: "numbers-proportions",
    group: "task1",
    band: "6.0",
    title: "Số liệu & tỉ lệ",
    en: "Numbers and Proportions",
    summary:
      "Bài này giúp viết đúng số liệu, phần trăm, phân số và cách ước lượng, đồng thời chia động từ đúng với chủ ngữ chứa số liệu. Lỗi ở những chi tiết nhỏ như 'millions' hay 'the number of … were' rất dễ làm tụt điểm Accuracy trong Task 1.",
    rules: [
      {
        title: "Percent và percentage",
        body: "Percent (hoặc per cent trong Anh-Anh) đứng sau con số và không bao giờ thêm s: 20 percent. Percentage là danh từ, đứng sau the/a và không đi kèm con số: the percentage of households. Khi một tỉ lệ thay đổi từ 30% lên 50%, mức tăng chính xác là 20 điểm phần trăm (percentage points).",
        form: "số + percent / per cent / %  |  the percentage / proportion / share + of + N",
        examples: [
          {
            en: "**The percentage of** households with solar panels rose to **15 per cent**.",
            vi: "Tỉ lệ hộ gia đình có tấm pin mặt trời tăng lên 15%.",
          },
          {
            en: "Internet use in Vietnam grew from 30% to 70%, a rise of **40 percentage points**.",
            vi: "Tỉ lệ dùng Internet ở Việt Nam tăng từ 30% lên 70%, tức tăng 40 điểm phần trăm.",
          },
        ],
      },
      {
        title: "Phân số và cách diễn đạt tỉ lệ (fractions & proportions)",
        body: "Thay vì lặp lại %, hãy dùng phân số (a quarter, a third, two thirds, half) hoặc cụm the majority / a minority / nearly half. Phân số có tử lớn hơn một thì mẫu thêm s (two thirds, three quarters).",
        form: "a quarter / a third / half / two thirds + of + N  |  the majority / a minority + of + N",
        examples: [
          {
            en: "**Nearly half of** all households heated their homes with gas.",
            vi: "Gần một nửa số hộ gia đình sưởi ấm bằng khí đốt.",
          },
          {
            en: "**Two thirds of** the electricity came from coal in 1990.",
            vi: "Năm 1990, hai phần ba lượng điện đến từ than.",
          },
          {
            en: "Only **a small minority of** drivers owned an electric car.",
            vi: "Chỉ một bộ phận nhỏ tài xế sở hữu xe điện.",
          },
        ],
      },
      {
        title: "Ước lượng số liệu (approximately, just over, well under)",
        body: "Khi số liệu không tròn, dùng approximately / around / roughly cho xấp xỉ, just over / just under cho chênh rất ít, well over / well under cho chênh khá nhiều. Kết hợp với phân số giúp diễn đạt tự nhiên và tránh liệt kê số khô khan.",
        form: "approximately / just over / well under + số hoặc phân số",
        examples: [
          {
            en: "**Just over a quarter** (26%) of the budget was spent on transport.",
            vi: "Hơn một phần tư một chút (26%) ngân sách được chi cho giao thông.",
          },
          {
            en: "Sales reached **approximately** 3 million units in 2020.",
            vi: "Doanh số đạt xấp xỉ 3 triệu chiếc vào năm 2020.",
          },
          {
            en: "Internet use in Laos remained **well under** 20% throughout the period.",
            vi: "Tỉ lệ dùng Internet ở Lào luôn thấp hơn hẳn mức 20% trong suốt giai đoạn.",
          },
        ],
      },
      {
        title: "Figure, number, amount và hòa hợp chủ ngữ – động từ (subject-verb agreement)",
        body: "The number of + N đếm được số nhiều, động từ chia số ít vì chủ ngữ chính là number; the amount of + N không đếm được; the figure for dùng chung cho mọi loại. Với phần trăm và phân số, động từ chia theo danh từ đứng sau of: 30% of the students were nhưng 30% of the water was.",
        form: "The number of + Ns + V số ít  |  % / phân số + of + N số nhiều → V số nhiều; N không đếm được → V số ít",
        examples: [
          {
            en: "**The number of** cars on the road **was** 5 million in 2010.",
            vi: "Số ô tô lưu thông năm 2010 là 5 triệu chiếc.",
          },
          {
            en: "**The amount of** water used by farms **was** far greater than that used by households.",
            vi: "Lượng nước các trang trại dùng lớn hơn nhiều so với lượng nước hộ gia đình dùng.",
          },
          {
            en: "Around **30% of the respondents were** satisfied with public transport.",
            vi: "Khoảng 30% người được khảo sát hài lòng với phương tiện công cộng.",
          },
        ],
      },
      {
        title: "Viết số đúng quy tắc (million, per cent, a 5-year period)",
        body: "Hundred, thousand, million đứng sau con số cụ thể thì không thêm s (2 million); chỉ dùng millions of khi không có số đứng trước. Cụm số + danh từ làm tính từ ghép phải có gạch nối và danh từ ở số ít (a 5-year period, a ten-year plan).",
        form: "số + million (không s)  |  millions of + N  |  a + số-N(số ít) + N",
        examples: [
          {
            en: "Vietnam exported **6 million** tonnes of rice in 2019.",
            vi: "Việt Nam xuất khẩu 6 triệu tấn gạo năm 2019.",
          },
          {
            en: "**Millions of** people moved to cities during the period.",
            vi: "Hàng triệu người chuyển đến thành phố trong giai đoạn này.",
          },
          {
            en: "The chart covers **a 20-year period** from 2000 to 2020.",
            vi: "Biểu đồ bao quát giai đoạn 20 năm từ 2000 đến 2020.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 1",
        tip: "Với biểu đồ tròn hoặc bảng phần trăm, đổi khoảng một nửa số liệu sang phân số kèm từ ước lượng và để số chính xác trong ngoặc. Cách này vừa đa dạng ngữ pháp vừa giữ độ chính xác.",
        example: "Just under a third of household energy (31%) was used for heating.",
      },
      {
        part: "Writing Task 1",
        tip: "Dùng the figure for / that of để chuyển chủ ngữ linh hoạt mà không lặp lại cả cụm danh từ dài, và nhớ chia động từ số ít khi chủ ngữ là the number / the figure.",
        example:
          "The number of internet users in Brazil was 120 million, while the figure for Mexico was just over half that.",
      },
      {
        part: "Writing Task 1",
        tip: "Trong câu tổng quan (overview), dùng the majority / a minority thay cho số liệu cụ thể để nêu bức tranh chung.",
        example:
          "Overall, the majority of electricity was generated from fossil fuels, while renewables accounted for only a small share.",
      },
    ],
    mistakes: [
      {
        wrong: "The percentage of people using buses increased 20 percents.",
        right: "The percentage of people using buses increased by 20 percentage points.",
        note: "Percent không có s, thiếu by, và mức thay đổi giữa hai tỉ lệ là percentage points.",
      },
      {
        wrong: "The number of cars were 5 millions.",
        right: "The number of cars was 5 million.",
        note: "Chủ ngữ chính là number nên động từ số ít; million sau con số không thêm s.",
      },
      {
        wrong: "The amount of tourists visiting Da Nang doubled.",
        right: "The number of tourists visiting Da Nang doubled.",
        note: "Tourists đếm được nên dùng number; amount chỉ đi với danh từ không đếm được.",
      },
      {
        wrong: "The data covers a 5-years period.",
        right: "The data covers a 5-year period.",
        note: "Trong tính từ ghép có gạch nối, danh từ luôn ở số ít.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "The ___ of households owning a car rose from 40% to 65%.",
        options: ["percent", "per cent", "percentage", "percents"],
        answer: 2,
        explain:
          "Sau the cần danh từ percentage. 'Percent' và 'per cent' chỉ đứng sau con số (40 percent); 'percents' không tồn tại trong cách viết số liệu.",
      },
      {
        type: "choice",
        q: "In 2020, 30% of the respondents ___ satisfied with public transport.",
        options: ["was", "were", "is", "has been"],
        answer: 1,
        explain:
          "Động từ chia theo danh từ sau of: respondents số nhiều nên dùng were; năm 2020 đã qua nên dùng quá khứ. 'Was' sai vì chia theo 30% thay vì respondents.",
      },
      {
        type: "choice",
        q: "The number of students ___ steadily over the decade.",
        options: ["have increased", "were increased", "increase", "increased"],
        answer: 3,
        explain:
          "Chủ ngữ chính là the number nên động từ số ít, và increase ở đây là nội động từ, quá khứ đơn là increased. 'Have increased' sai hòa hợp; 'were increased' dùng bị động sai.",
      },
      {
        type: "choice",
        q: "The country produced 2 ___ tonnes of rice in 2010.",
        options: ["millions", "million", "millions of", "million of"],
        answer: 1,
        explain:
          "Có con số 2 đứng trước nên million không thêm s và không có of. 'Millions of' chỉ dùng khi không có số cụ thể (millions of tonnes).",
      },
      {
        type: "choice",
        q: "The ___ of water used by farms was far greater than that used by households.",
        options: ["number", "amount", "many", "numbers"],
        answer: 1,
        explain:
          "Water không đếm được nên dùng amount. 'Number' chỉ đi với danh từ đếm được số nhiều (the number of farms).",
      },
      {
        type: "choice",
        q: "Just under ___ of the budget (24%) was spent on education.",
        options: ["a third", "the majority", "a quarter", "half"],
        answer: 2,
        explain:
          "24% thấp hơn 25% một chút nên là just under a quarter. 'A third' (khoảng 33%) quá xa, 'the majority' nghĩa là trên 50%.",
      },
      {
        type: "fill",
        q: "Unemployment fell by 3 ___ cent over the period.",
        hint: "(cách viết 'phần trăm' kiểu Anh-Anh, hai từ)",
        answers: ["per"],
        explain:
          "Anh-Anh viết per cent, Anh-Mỹ viết percent; cả hai đều không thêm s sau con số.",
      },
      {
        type: "fill",
        q: "Car ownership grew steadily over a ten-___ period.",
        hint: "(year)",
        answers: ["year"],
        explain:
          "Ten-year là tính từ ghép bổ nghĩa cho period nên danh từ giữ số ít, không viết ten-years.",
      },
      {
        type: "fill",
        q: "Approximately two ___ of the energy (66%) came from coal.",
        hint: "(phân số 2/3)",
        answers: ["thirds"],
        explain:
          "Tử số lớn hơn một thì mẫu số thêm s: two thirds. 'Two third' là lỗi thường gặp.",
      },
      {
        type: "fill",
        q: "The ___ of the students (52%) preferred online classes.",
        hint: "(phần lớn, đa số)",
        answers: ["majority"],
        explain:
          "52% vượt quá một nửa nên dùng the majority of. 'Minority' sai nghĩa vì chỉ phần nhỏ hơn một nửa.",
      },
    ],
  },

  // ---------------------------------------------------------------------------
  // 4. Mệnh đề danh từ & cấu trúc It
  // ---------------------------------------------------------------------------
  {
    id: "noun-clauses",
    group: "task1",
    band: "6.0",
    title: "Mệnh đề danh từ & cấu trúc It",
    en: "Noun Clauses and It-structures",
    summary:
      "Bài này dạy cách dùng mệnh đề danh từ (that, what, whether, wh-) và cấu trúc It is … that để nêu quan điểm, tường thuật ý kiến và đặt câu hỏi gián tiếp. Đây là nhóm câu phức xuất hiện dày đặc trong Writing Task 2 và Speaking.",
    rules: [
      {
        title: "Mệnh đề that làm tân ngữ và chủ ngữ (that-clauses)",
        body: "Mệnh đề danh từ (noun clause) là cả một mệnh đề đóng vai trò danh từ trong câu. Mệnh đề that thường làm tân ngữ sau believe, think, agree; khi làm chủ ngữ, câu rất trang trọng nên người viết thường chuyển sang cấu trúc It is … that.",
        form: "S + believe / think / agree + that + S + V  |  That + S + V + V …",
        examples: [
          {
            en: "Many people **believe that** university education should be free.",
            vi: "Nhiều người tin rằng giáo dục đại học nên miễn phí.",
          },
          {
            en: "**That the climate is changing** is beyond doubt.",
            vi: "Việc khí hậu đang thay đổi là điều không thể nghi ngờ.",
          },
        ],
      },
      {
        title: "Mệnh đề what (what-clauses)",
        body: "What nghĩa là 'điều mà / cái mà', mở đầu một mệnh đề danh từ làm chủ ngữ hoặc tân ngữ. Câu What … is … đưa thông tin quan trọng ra cuối để nhấn mạnh; động từ chính sau mệnh đề what thường là is.",
        form: "What + S + V + is + N / that-clause  |  S + V + what + S + V",
        examples: [
          {
            en: "**What concerns me is** the rising cost of housing.",
            vi: "Điều khiến tôi lo ngại là chi phí nhà ở ngày càng tăng.",
          },
          {
            en: "**What I like most about my hometown is** the street food.",
            vi: "Điều tôi thích nhất ở quê mình là đồ ăn đường phố.",
          },
          {
            en: "Governments should listen to **what young people need**.",
            vi: "Chính phủ nên lắng nghe điều người trẻ cần.",
          },
        ],
      },
      {
        title: "Câu hỏi gián tiếp: wh-, whether / if (indirect questions)",
        body: "Khi câu hỏi nằm bên trong một câu khác, mệnh đề dùng trật tự câu khẳng định (chủ ngữ trước động từ) và bỏ trợ động từ do/does/did. Câu hỏi có/không chuyển thành whether hoặc if; sau giới từ, sau be và khi làm chủ ngữ thì chỉ dùng whether.",
        form: "… + wh-word + S + V  |  … + whether / if + S + V",
        examples: [
          {
            en: "I wonder **why people are** so attached to their phones.",
            vi: "Tôi tự hỏi vì sao mọi người lại gắn bó với điện thoại đến thế.",
          },
          {
            en: "Could you tell me **where the station is**?",
            vi: "Bạn có thể cho tôi biết nhà ga ở đâu không?",
          },
          {
            en: "The question is **whether** the policy will work in rural areas.",
            vi: "Vấn đề là liệu chính sách này có hiệu quả ở nông thôn hay không.",
          },
        ],
      },
      {
        title: "Cấu trúc It + be + tính từ + that / to-V",
        body: "It làm chủ ngữ giả (dummy subject), còn chủ ngữ thật là mệnh đề that hoặc cụm to-V đặt ở cuối câu. Tiếng Việt hay bỏ chủ ngữ ('Rõ ràng là…') nên người học dễ quên It; trong tiếng Anh câu bắt buộc phải có chủ ngữ.",
        form: "It is + adj + that + S + V  |  It is + adj + (for sb) + to + V",
        examples: [
          {
            en: "**It is clear that** technology has changed the way we work.",
            vi: "Rõ ràng là công nghệ đã thay đổi cách chúng ta làm việc.",
          },
          {
            en: "**It is difficult to** predict how the job market will change.",
            vi: "Thật khó dự đoán thị trường việc làm sẽ thay đổi thế nào.",
          },
          {
            en: "**It is evident that** more investment in public transport is needed.",
            vi: "Hiển nhiên là cần đầu tư nhiều hơn cho giao thông công cộng.",
          },
        ],
      },
      {
        title: "Động từ tường thuật + that (argue, claim, suggest)",
        body: "Argue, claim, maintain, suggest, point out + that dùng để trình bày quan điểm của người khác trong bài luận. Riêng suggest/recommend/insist that + S + (should) + V nguyên mẫu, kể cả khi chủ ngữ số ít.",
        form: "S + argue / claim + that + S + V  |  S + suggest + that + S + (should) + V (nguyên mẫu)",
        examples: [
          {
            en: "Critics **argue that** social media harms teenagers' mental health.",
            vi: "Những người phản đối cho rằng mạng xã hội gây hại cho sức khỏe tinh thần của thanh thiếu niên.",
          },
          {
            en: "Some experts **suggest that** the government **invest** more in renewable energy.",
            vi: "Một số chuyên gia đề xuất chính phủ đầu tư nhiều hơn vào năng lượng tái tạo.",
          },
          {
            en: "Supporters **claim that** online learning is just as effective as classroom teaching.",
            vi: "Những người ủng hộ khẳng định học trực tuyến hiệu quả không kém học trên lớp.",
          },
        ],
      },
    ],
    ielts: [
      {
        part: "Writing Task 2",
        tip: "Mở bài và thân bài nên có ít nhất một cấu trúc It is + adj/V3 + that và một động từ tường thuật để trình bày hai phía của vấn đề một cách khách quan. Tránh lặp 'I think' nhiều lần.",
        example:
          "It is widely argued that tuition fees should be abolished; however, others claim that this would place an excessive burden on taxpayers.",
      },
      {
        part: "Writing Task 2",
        tip: "Dùng câu What … is … để nhấn mạnh luận điểm chính ở đầu đoạn thân bài hoặc kết bài; đây là cấu trúc câu phức giám khảo dễ nhận ra.",
        example:
          "What is often overlooked is that remote work can widen the gap between urban and rural workers.",
      },
      {
        part: "Speaking",
        tip: "Ở Part 1 và Part 3, câu hỏi gián tiếp giúp bạn có thời gian suy nghĩ mà vẫn thể hiện ngữ pháp. Nhớ giữ trật tự chủ ngữ trước động từ trong mệnh đề.",
        example:
          "I'm not sure whether I'd call myself a sporty person, but I've often wondered why so many people enjoy running marathons.",
      },
    ],
    mistakes: [
      {
        wrong: "I don't know what is it.",
        right: "I don't know what it is.",
        note: "Trong câu hỏi gián tiếp, chủ ngữ đứng trước động từ như câu khẳng định.",
      },
      {
        wrong: "Can you tell me where does she live?",
        right: "Can you tell me where she lives?",
        note: "Câu hỏi gián tiếp bỏ trợ động từ does và động từ chính chia theo chủ ngữ.",
      },
      {
        wrong: "Is clear that technology makes our lives easier.",
        right: "It is clear that technology makes our lives easier.",
        note: "Câu tiếng Anh bắt buộc có chủ ngữ, nên phải dùng It làm chủ ngữ giả.",
      },
      {
        wrong: "What I want to say that education is important.",
        right: "What I want to say is that education is important.",
        note: "Mệnh đề what là chủ ngữ nên câu vẫn cần động từ chính is.",
      },
    ],
    exercises: [
      {
        type: "choice",
        q: "I don't know what ___.",
        options: ["is it", "it is", "does it mean", "is it meaning"],
        answer: 1,
        explain:
          "Câu hỏi gián tiếp dùng trật tự khẳng định: what it is. 'Is it' và 'does it mean' giữ trật tự câu hỏi trực tiếp nên sai.",
      },
      {
        type: "choice",
        q: "___ young people spend too much time online is widely accepted.",
        options: ["It", "What", "Which", "That"],
        answer: 3,
        explain:
          "Mệnh đề làm chủ ngữ đã đầy đủ (young people spend too much time online) nên dùng That. 'What' chỉ dùng khi mệnh đề thiếu một thành phần (What worries me …); 'It' cần cấu trúc It is accepted that.",
      },
      {
        type: "choice",
        q: "___ worries me most is the rising cost of housing.",
        options: ["That", "What", "It", "Which"],
        answer: 1,
        explain:
          "Mệnh đề thiếu chủ ngữ cho worries nên cần What (= điều mà). 'That' chỉ mở mệnh đề đã đủ thành phần; 'It worries me most is' có hai động từ chính nên sai.",
      },
      {
        type: "choice",
        q: "I'm not sure ___ this policy will work in rural areas.",
        options: ["whether", "that", "what", "which"],
        answer: 0,
        explain:
          "Not sure diễn tả nghi vấn có/không nên dùng whether (hoặc if). 'That' mang nghĩa khẳng định, mâu thuẫn với not sure; 'what' cần mệnh đề thiếu thành phần.",
      },
      {
        type: "choice",
        q: "It is essential ___ children learn to swim at an early age.",
        options: ["what", "whether", "to", "that"],
        answer: 3,
        explain:
          "Sau It is essential là mệnh đề đầy đủ (children learn …) nên dùng that. 'To' chỉ đi với động từ nguyên mẫu (It is essential to learn), không đi với cả mệnh đề có chủ ngữ.",
      },
      {
        type: "choice",
        q: "Some experts suggest that the government ___ taxes on sugary drinks.",
        options: ["raises up", "to raise", "raise", "raising"],
        answer: 2,
        explain:
          "Suggest that + S + (should) + V nguyên mẫu nên dùng raise dù chủ ngữ số ít. 'To raise' và 'raising' không làm động từ chính của mệnh đề that.",
      },
      {
        type: "fill",
        q: "Could you tell me where the station ___?",
        hint: "(be)",
        answers: ["is"],
        explain:
          "Câu hỏi gián tiếp đặt động từ sau chủ ngữ: where the station is. Không viết 'where is the station' trong câu gián tiếp.",
      },
      {
        type: "fill",
        q: "It is clear ___ technology has changed the way we work.",
        hint: "(từ mở đầu mệnh đề danh từ)",
        answers: ["that"],
        explain:
          "It is clear that + mệnh đề đầy đủ là cấu trúc cố định. Không dùng 'what' vì mệnh đề phía sau không thiếu thành phần nào.",
      },
      {
        type: "fill",
        q: "The question is ___ the plan will succeed.",
        hint: "(liệu … có … hay không)",
        answers: ["whether"],
        explain:
          "Sau động từ be, mệnh đề có/không phải dùng whether chứ không dùng if. 'That' sai vì câu mang nghĩa nghi vấn.",
      },
      {
        type: "fill",
        q: "___ we should do now is invest in renewable energy.",
        hint: "(điều mà)",
        answers: ["what"],
        explain:
          "Mệnh đề làm chủ ngữ thiếu tân ngữ của do nên cần What. 'That' không thay được vì that không đóng vai trò tân ngữ trong mệnh đề.",
      },
    ],
  },
];
