//
//  Nomin's first application:

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var diceOne: UIImageView!
    @IBOutlet weak var diceTwo: UIImageView!
    @IBOutlet weak var rollButton: UIButton!
    
    let diceImages = ["DiceOne", "DiceTwo", "DiceThree", "DiceFour", "DiceFive", "DiceSix"]
    
    var rollCount = 0
    
    var favoriteNumber: Int?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initial images to show up!
        diceOne.image = UIImage(imageLiteralResourceName: "DiceTwo")
        diceTwo.image = UIImage(imageLiteralResourceName: "DiceThree")
        
        // button style costumizer
        rollButton.layer.cornerRadius = rollButton.frame.height / 2
        rollButton.layer.masksToBounds = true
        
        //Let the audio speak!
        if let path = Bundle.main.path(forResource: "fasterButtonClick", ofType: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayer?.prepareToPlay()
                } catch {
                    print("Error loading audio file")
                }
            }
        
        do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session setup error: \(error)")
            }
    }

    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            askLuckyNumber()
        }

    @IBAction func rollButton(_ sender: UIButton) {
        rollCount += 1
        audioPlayer?.play()
        
        let firstDiceIndex = Int.random(in: 0...5)
        let secondDiceIndex = Int.random(in: 0...5)
        

        diceOne.image = UIImage(named: diceImages[firstDiceIndex])
        diceTwo.image = UIImage(named: diceImages[secondDiceIndex])
        
        // now I want to the app to show a pop up saying "Congrats! You are the luckiest today!"
        // if images for diceOne and diceTwo is both 6
        let roundedValue = roundToDecimalPlaces(value: (36.0/Double(rollCount))*100, places: 4)
        
        let message  =  "It took you whopping \(rollCount) rolls to get double sixes. Your luck is \(roundedValue) %"
        
        if secondDiceIndex == 5 && firstDiceIndex == 5 {
            let alert = UIAlertController(title: "Congratulations!",
                                          message:message , preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"Congrats\" alert occured.")
                    }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if let favNumber = favoriteNumber, firstDiceIndex == favNumber - 1, secondDiceIndex == favNumber - 1 {
                    let luckyMessage = "You rolled your favorite number (\(favNumber)) on both dice!"
                    let luckyAlert = UIAlertController(title: "Lucky Roll!", message: luckyMessage, preferredStyle: .alert)
                    luckyAlert.addAction(UIAlertAction(title: "Awesome!", style: .default))
                    self.present(luckyAlert, animated: true, completion: nil)
                }
        
    }
    
    func roundToDecimalPlaces(value: Double, places: Int) -> Double {
        let decimalNumber = NSDecimalNumber(value: value)
        let behavior = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(places), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedNumber = decimalNumber.rounding(accordingToBehavior: behavior)
        return roundedNumber.doubleValue
    }
    
    func askLuckyNumber() {
        let alertController = UIAlertController(title: "Favorite Number", message: "Enter your favorite number between 1 and 6", preferredStyle: .alert)
        
        alertController.addTextField { textField in
                textField.placeholder = "Number here"
                textField.keyboardType = .numberPad
            }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    if let textField = alertController.textFields?.first, let text = textField.text, let number = Int(text), number >= 1, number <= 6 {
                        self?.favoriteNumber = number
                    } else {
                        self?.showErrorAlert()
                    }
                }
                
        
        alertController.addAction(confirmAction)
            present(alertController, animated: true, completion: nil)

    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Please enter a number between 1 and 6", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self] _ in self?.askLuckyNumber()
        })
        self.present(alert, animated: true, completion: nil)
    }
}

