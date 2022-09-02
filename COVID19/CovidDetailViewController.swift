//
//  CovidDetailViewController.swift
//  COVID19
//
//  Created by Gunter on 2021/09/19.
//

import UIKit

class CovidDetailViewController: UITableViewController {
  @IBOutlet weak var newCaseCell: UITableViewCell!
  @IBOutlet weak var totalCaseCell: UITableViewCell!
  @IBOutlet weak var recoveredCell: UITableViewCell!
  @IBOutlet weak var deathCell: UITableViewCell!
  @IBOutlet weak var percentageCell: UITableViewCell!
  @IBOutlet weak var overseasInflowCell: UITableViewCell!
  @IBOutlet weak var regionalOutbreakCell: UITableViewCell!

  //해당 프로퍼티로 선택된 지역의 데이터를 전달 받음
  var covidOverview: CovidOverview?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureView()
  }

  func configureView() {
    guard let covidOverview = self.covidOverview else { return }
    self.title = covidOverview.countryName
    //신규 확진자
    self.newCaseCell.detailTextLabel?.text = "\(covidOverview.newCase)명"
    //총 확진자
    self.totalCaseCell.detailTextLabel?.text = "\(covidOverview.totalCase)명"
    //완치자 수
    self.recoveredCell.detailTextLabel?.text = "\(covidOverview.recovered)명"
    //사망자 수
    self.deathCell.detailTextLabel?.text = "\(covidOverview.death)명"
    //발생 률
    self.percentageCell.detailTextLabel?.text = "\(covidOverview.percentage)%"
    //해외 유입 신규 확진자
    self.overseasInflowCell.detailTextLabel?.text = "\(covidOverview.newFcase)명"
    //지역발생 신규 환지 자수
    self.regionalOutbreakCell.detailTextLabel?.text = "\(covidOverview.newCcase)명"
  }
}
