//
//  HistoricalOrderVC.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/8.
//
import OSLog
import UIKit

class HistoricalOrderVC: UIViewController {
    // MARK: Properties
    private let logger = Logger(subsystem: "HistoricalOrders", category: "HistoricalOrderVC")
//    private var viewModel =
    var currentDevice: Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UITabBarControllerDelegate
extension HistoricalOrderVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0:
            let vc = viewController as! MenuVC
            vc.currentDevice = currentDevice

        case 1:
            let vc = viewController as! EatInVC
            vc.currentDevice = currentDevice

        case 2:
            let vc = viewController as! TakeOutOrderVC
            vc.currentDevice = currentDevice

        case 3:
            let vc = viewController as! HistoricalOrderVC
            vc.currentDevice = currentDevice

        default:
            logger.error("unrecognized view controller")
        }
    }
}
