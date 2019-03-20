//
//  HomeViewController.swift
//  DiceKey
//
//  Created by Peter on 19/03/19.
//  Copyright © 2019 Fontaine. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var brainWallet = Bool()
    var normalWallet = Bool()
    var diceWallet = Bool()
    @IBOutlet var homeTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController!.delegate = self
        homeTable.delegate = self
        homeTable.dataSource = self
        homeTable.tableFooterView = UIView(frame: .zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        brainWallet = false
        normalWallet = false
        diceWallet = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "goToKeyCreator":
            
            if let vc = segue.destination as? DiceViewController {
                
                if brainWallet {
                    
                    vc.brainWallet = true
                    
                }
                
                if normalWallet {
                    
                    vc.normalWallet = true
                    
                }
                
                if diceWallet {
                    
                    vc.diceWallet = true
                    
                }
                
            }
            
        default:
            
            break
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = homeTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        let imageView = cell.viewWithTag(2) as! UIImageView
        
        switch indexPath.row {
            
        case 0:
            
            label.text = "Create Keys Now"
            imageView.image = UIImage(named: "keys.png")
            
        case 1:
            
            label.text = "Create Brain Wallet"
            imageView.image = UIImage(named: "brainWallet.png")
            
        case 2:
            
            label.text = "Create Keys with Dice"
            imageView.image = UIImage(named: "whiteDice.png")
            
        default:
            
            break
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.homeTable.cellForRow(at: indexPath)!
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.05, animations: {
                
                cell.alpha = 0
                
            }) { _ in
                
                UIView.animate(withDuration: 0.2, animations: {
                    
                    cell.alpha = 1
                    
                })
                
            }
            
        }
        
        switch indexPath.row {
            
        case 0:
            
            normalWallet = true
            performSegue(withIdentifier: "goToKeyCreator", sender: self)
            
        case 1:
            
            brainWallet = true
            performSegue(withIdentifier: "goToKeyCreator", sender: self)
            
        case 2:
            
            diceWallet = true
            performSegue(withIdentifier: "goToKeyCreator", sender: self)
            
        default:
            
            break
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    

}

extension HomeViewController  {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return MyTransition(viewControllers: tabBarController.viewControllers)
        
    }
    
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.5
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart
        
        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
    
}
