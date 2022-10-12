

import UIKit
import Alamofire
import Charts

class ViewController: UIViewController {
  @IBOutlet weak var totalCaseLabel: UILabel!
  @IBOutlet weak var newCaseLabel: UILabel!
    //Chart라이브러리 에 포함됨
  @IBOutlet weak var pieChartView: PieChartView!
  @IBOutlet weak var labelStackView: UIStackView!
  @IBOutlet weak var indicatorView: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()
    //인디케이터(로딩) 애니메이션 시작
    self.indicatorView.startAnimating()
    //앱이 실행될 때 시도별 코로나 현황 api를 호출
    //순환 참조 방지용 [weak self]
    self.fetchCovidOverview(completionHandler: { [weak self] result in
        //일시 적으로 self가 strong 레퍼런스가 되게 만들어줌
      guard let self = self else { return }
        //응답을 받으면 로딩 멈춤
      self.indicatorView.stopAnimating()
        //인디케이터 뷰 가림
      self.indicatorView.isHidden = true
        //응답이 왔기 때문에 스택 뷰와 파이차트 뷰를 표시함
      self.labelStackView.isHidden = false
      self.pieChartView.isHidden = false
      switch result {
      case let .success(result):
        //Alamofire의 네트워크 동작은 메인 스레드에서 동작 하기 때문에
        //UI작업위해 추가 작업 필요X
        self.configureStackView(koreaCovidOverview: result.korea)
        let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
        self.configureChartView(covidOverviewList: covidOverviewList)

      case let .failure(error):
        debugPrint("failure \(error)")
      }
    })
  }

  func makeCovidOverviewList(cityCovidOverview: CityCovidOverview) -> [CovidOverview] {
    return [
      cityCovidOverview.seoul,
      cityCovidOverview.busan,
      cityCovidOverview.daegu,
      cityCovidOverview.incheon,
      cityCovidOverview.gwangju,
      cityCovidOverview.daejeon,
      cityCovidOverview.ulsan,
      cityCovidOverview.sejong,
      cityCovidOverview.gyeonggi,
      cityCovidOverview.chungbuk,
      cityCovidOverview.chungnam,
      cityCovidOverview.jeonnam,
      cityCovidOverview.gyeongbuk,
      cityCovidOverview.gyeongnam,
      cityCovidOverview.jeju,
    ]
  }

  func configureStackView(koreaCovidOverview: CovidOverview) {
    self.totalCaseLabel.text = "\(koreaCovidOverview.totalCase) 명"
    self.newCaseLabel.text = "\(koreaCovidOverview.newCase) 명"
  }

    //파이 차트에 데이터를 표시 하려면 PieChartDataEntry객체에 데이터를 추가 시켜줘야함
  func configureChartView(covidOverviewList: [CovidOverview]) {
    self.pieChartView.delegate = self
    //[CovidOverview]를 PieChartDataEntry로 맵핑
    let entries = covidOverviewList.compactMap { [weak self] overview -> PieChartDataEntry? in
      guard let self = self else { return nil }
        //value 파라미터 에는 차트 항목에 들어가는 값을 넣어주면됨, 시도 별 신규 확진자 수가 차트의 값이 되게 만들어줌
        //overview.newCase를 넣으면 에러가 남, 그이유는 value 에는 더블 타입 넘겨 주어야 하는데 String 타입 넘겨줘서 에러남
        
        //label파라미터에는 파이차트에 표시할 이름을 넘겨주면됨(도시 이름)
        
        //data파라 미터에는 overview를 넣어줘서 시도별 코로나 현황의 상세 데이터를 가질수 있게 만들어줌
      return PieChartDataEntry(
        value: self.removeFormatString(string: overview.newCase),
        label: overview.countryName,
        data: overview
      )
    }
    //entries에는 PieChartDataEntry객체를 넘겨줌
    let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
    //항목 간 간격
    dataSet.sliceSpace = 1
    //항목 이름 색 검정
    dataSet.entryLabelColor = .black
    //항목이름이 바깥쪽 선으로 표시
    dataSet.xValuePosition = .outsideSlice
    //파이 차트 안에 있는 값도 검정으로 표시
    dataSet.valueTextColor = .black
    dataSet.valueLinePart1OffsetPercentage = 0.8
    dataSet.valueLinePart1Length = 0.2
    dataSet.valueLinePart2Length = 0.3
    
    //파이 차트를 다양한 색상으로 표시
    dataSet.colors = ChartColorTemplates.vordiplom()
      + ChartColorTemplates.joyful()
      + ChartColorTemplates.colorful()
      + ChartColorTemplates.liberty()
      + ChartColorTemplates.pastel()
      + ChartColorTemplates.material()
    //시도별 신규 확진자 수가 파이차트로 표시됨
    self.pieChartView.data = PieChartData(dataSet: dataSet)
    //spin메소드 호출을 통해 파이차트 80도 회전
    //duration: 애니메이션 지속 시간
    
    //fromAngle: 현재 앵글
    
    //toAngle: 현재 앵글에서 + x만큼 회전된 상태
    self.pieChartView.spin(duration: 0.3, fromAngle: pieChartView.rotationAngle, toAngle: pieChartView.rotationAngle + 80)
  }

  func removeFormatString(string: String) -> Double {
    let formatter = NumberFormatter()
    //3자리 마다 컴마를 찍는 포맷의 숫자를, 그냥숫자로 변경 함
    formatter.numberStyle = .decimal
    //더블 밸류로 바꿔줌
    return formatter.number(from: string)?.doubleValue ?? 0
  }

    //api를 요청하고 서버에서 json데이터를 응답 받거나
    //요청이 실패 하였을 때 completionHandler 클로저를 호출 하여
    //해당 클로저를 정의 하는곳에 응답받은 데이터를 전달함
    
    //요청에 성공하면 열거형 연관값으로 CityCovidOverview 객체를 받고
    //실패하거나 에러 사항이면 열거형 연관값으로 Error 객체를 받음
    
    //@escaping 클로저는 비동기 작업 할 때 많이 사용함
    //함수 인자로 클로저가 전달 되지만 함수가 반환된 후에도 실행 되는 것을 의미함
    //함수의 인자가 함수의 영역을 탈출하여 함수 밖에서도 사용 할 수 있는 개념은 기존의 변수의 스코프 개념을 무시함
    //함수의 지역 변수의 영역이 함수 밖을 넘어서도 유효하기 때문
    //보통 네트워크 통신은 비동기 방식으로 작업 되기 떄문에
    //.responseData 에 정의 한 completionHandler는 fetchCovidOverview 함수가 반환 된 후에 호출됨
    //그 이유는 서버에서 데이터를 언제 응답 시켜줄지 모르기 때문이다
    //그렇기 때문에 @escaping 클로저로 completionHandler를 정의 하지 않는다면
    //서버에서 비동기로 데이터를 응답받기전
    //즉 .responseData 에 정의 한 completionHandler클로저가 호출되기 전에 함수가 종료되서
    //서버에 응답을 받아도 우리가 fetchCovidOverview 에 정의한 completionHandler 호출 되지 않을것
    //그렇기 때문에 함수내에서 비동기작업을 하고 비동기 작업의 결과를 completionHandler콜백 시켜줘야 한다
    //@escaping 클로저를 사용하여 함수가 반환된 후에도 실행되게 만들어 줘야 한다
  func fetchCovidOverview(
    completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
  ) {
    let url = "https://api.corona-19.kr/korea/country/new/"
    let param = [
        "serviceKey": Bundle.main.apiKey
    ]
    //Alamofire를 이용하여 api를 호출
    //parameters: 에 딕셔너리 형태로 전달하면 알아서 url 뒤에 쿼리를 추가함
    
    //request메소드를 이용하여 api호출을 하였으면
    //응답 데이터를 받을 수 있는 메소드를 체이닝 해주어야 한다 (.responseData 해주면 됨)
    //completionHandler: 정의 해주면, 응답 데이터가 클로저 파라미터로 전달됨
    AF.request(url, method: .get, parameters: param)
      .responseData(completionHandler: { response in
        //response는 enum
        switch response.result {
        //성공시 서버에서 응답 받은 데이터가 전달됨
        case let .success(data):
          do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(CityCovidOverview.self, from: data)
            //json객체가 CityCovidOverview로 맵핑 성공, 연관값 CityCovidOverview객체 전달
            completionHandler(.success(result))
          } catch {
            //맵핑 실패, 연관값에 Error객체 전달
            completionHandler(.failure(error))
          }
        //요청 실패
        case let .failure(error):
          completionHandler(.failure(error))
        }
      })
  }
}

extension ViewController: ChartViewDelegate {
    //차트에서 항목을 선택 하였을 때 호출되는 메소드
    //entry 파라미터를 통해 선택된 항목에 대한 데이터를 가져올 수 있다
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    //스토리 보드에 있는 "CovidDetailViewController"를 인스턴스 화 시킴
    guard let covidDetailViewController = self.storyboard?.instantiateViewController(identifier: "CovidDetailViewController") as? CovidDetailViewController else {
         return
       }
    guard let covidOverview = entry.data as? CovidOverview else { return }
    //선택된 항목에 저장된 데이터를 전달함
    covidDetailViewController.covidOverview = covidOverview
    //네비게이션 컨트롤러 스택에 push 되어 화면을 보여준다
    self.navigationController?.pushViewController(covidDetailViewController, animated: true)
  }
}

