//
//  ViewController.swift
//  Pomodoro
//
//  Created by YONGCHEOL LEE on 2021/11/16.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressVIew: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToggleButton()
    }
    
    func setTimerInfoViewVisble(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressVIew.isHidden = isHidden
    }
    
    func configureToggleButton() {
        toggleButton.setTitle("시작", for: .normal)
        toggleButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            timer?.schedule(deadline: .now(), repeating: 1)
            timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
//                debugPrint(self?.currentSeconds)
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                self.progressVIew.progress = Float(self.currentSeconds) / Float(self.duration)
//                debugPrint(self.progressVIew.progress)
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                if self.currentSeconds <= 0 {
                    // terminate timer
                    self.stopTimer()
                    // system alarm sound = 1005
                    AudioServicesPlaySystemSound(1005)
                }
            })
            timer?.resume()
        }
    }
    
    func stopTimer() {
        if timerStatus == .pause {
            timer?.resume()
        }
        
        timerStatus = .end
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressVIew.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })
//        setTimerInfoViewVisble(isHidden: true)
//        datePicker.isHidden = false
        cancelButton.isEnabled = false
        toggleButton.isSelected = false
        timer?.cancel()
        timer = nil
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        switch timerStatus {
        case .start, .pause:
            stopTimer()
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: Any) {
        duration = Int(datePicker.countDownDuration)
//        debugPrint(self.duration)
        switch self.timerStatus {
        case .end:
            currentSeconds = duration
            timerStatus = .start
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressVIew.alpha = 1
                self.datePicker.alpha = 0
            })
            
//            setTimerInfoViewVisble(isHidden: false)
//            datePicker.isHidden = true
            toggleButton.isSelected = true
            cancelButton.isEnabled = true
            startTimer()
            
        case .start:
            timerStatus = .pause
            toggleButton.isSelected = false
            timer?.suspend()
        case .pause:
            timerStatus = .start
            toggleButton.isSelected = true
            timer?.resume()
        }
    }
    
}

