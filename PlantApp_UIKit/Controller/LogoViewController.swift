//
//  LogoViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 1/1/23.
//

import UIKit
import FirebaseAuth

class LogoViewController: UIViewController {
    
    let titleLogo = UIImageView()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        // Do any additional setup after loading the view.
        
        //Title Logo: UIImageView
        view.addSubview(titleLogo)
        titleLogo.translatesAutoresizingMaskIntoConstraints = false
        titleLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLogo.heightAnchor.constraint(equalToConstant: 200).isActive = true
        titleLogo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        titleLogo.image = UIImage(named: K.leaf)
        // Animate title logo.
        titleLogo.alpha = 0 // or newImage.fadeOut(duration: 0.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name("logoutTriggered"), object: nil)
        
        titleLogo.fadeInAnimation {
            if self.authenticateFBUser() || self.defaults.bool(forKey: "useWithoutFBAccount") {
                K.navigateToMainVC(self)
            } else {
                let vc = LoginViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
        
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

public extension UIView {

    func fadeInAnimation(duration: TimeInterval = 0.5, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        } completion: { _ in
            print("Animation completed")
            completion()
//            let defaults = UserDefaults.standard
//            defaults.set(true, forKey: "LogoVCDisplayCompleted")
        }
    }

}

extension LogoViewController {
    
    func authenticateFBUser() -> Bool {
        if Auth.auth().currentUser?.uid != nil {
            return true
        } else {
            return false
        }
    }
    
    @objc func reloadView() {
        if defaults.bool(forKey: "loginVCReload") {
            self.viewDidLoad()
            defaults.set(false, forKey: "loginVCReload")
        }
    }
}
