//
//  ViewController.swift
//  Project2
//
//  Created by Yulian Gyuroff on 20.09.23.
//
import UserNotifications
import UIKit

class ViewController: UIViewController,UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var lastScore = 0
    var correctAnswer = 0
    var tries = 0
    var correctGuesses = 0
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showScore))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        
        if let savedScore = defaults.object(forKey: "savedScore") as? Int {
            lastScore = savedScore
        }
        
        countries += ["estonia","france","germany",
                      "ireland","italy","monaco","nigeria",
                      "poland","russia","spain","uk","us"]
        
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        button1.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button2.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button3.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil){
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        button1.transform = .identity
        button2.transform = .identity
        button3.transform = .identity
        
        //title = "Tap flag for: " + countries[correctAnswer].uppercased() + " /score:\(score)/"
        let label: UILabel = UILabel(frame: CGRectMake(0, 0, 400, 50))
        label.backgroundColor = UIColor.placeholderText
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.label
        label.text = "Tap flag for: " + countries[correctAnswer].uppercased() + "\nscore:\(score)"
        self.navigationItem.titleView = label
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        var wrongFlagText: String = ""
        var completed10FlagText: String = ""
        var recordScore = false
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5,options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85) }){finished in
                print("scaleDown button flag")
            }
         
        if sender.tag == correctAnswer{
            title = "Correct"
            score += 1
            defaults.set(score,forKey: "savedScore")
            correctGuesses += 1
        }else{
            title = "Wrong"
            score -= 1
            defaults.set(score,forKey: "savedScore")
            wrongFlagText = "That is the flag of \(countries[sender.tag].uppercased())\n"
        }
        tries+=1
        completed10FlagText = tries%10==0 ? "Complete 10 flags" : ""
        if score > lastScore {
            recordScore = true
        }else{
            recordScore = false
        }
        let ac = UIAlertController(title: title,
                                   message: "\( wrongFlagText )\nYour score is \(recordScore ? "record: ":"")\(score)\n\(completed10FlagText)",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    @objc func showScore(){
        let ac = UIAlertController(title: "Guessed Flags",
                                   message: "Your score is \(score)\nCorrect Answers: \(correctGuesses)\nNumber of games: \(tries)",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default))
        present(ac, animated: true)
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.badge,.sound]) { granted, error in
            if granted {
                print("Yay! - Granted!")
                self.scheduleLocal()
            }else{
                print("Oh no! - Not Granted!")
            }
        }
    }
    
    func scheduleLocal() {
            registerCategories()
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            
            let content = UNMutableNotificationContent()
            content.title = "Guess the Flag"
            content.body = "You haven't forgot the game, have you?"
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = .default
        
            var dateComponents = DateComponents()
            dateComponents.hour = 18
            dateComponents.minute = 53
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalForNextAlert, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            
        }
    
    func registerCategories() {
           let center = UNUserNotificationCenter.current()
           center.delegate = self
           
           let show = UNNotificationAction(identifier: "show", title: "Tell me more...",options: .foreground)
           //let later = UNNotificationAction(identifier: "later", title: "Remind me later...",options: .foreground)
           let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
           center.setNotificationCategories([category])
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //user swiped to unlock
                print("default identifier")
            case "show":
                print("Show more information...")
            default:
                break
            }
        }
    }
}

