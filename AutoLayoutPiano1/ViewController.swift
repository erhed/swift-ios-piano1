//
//  ViewController.swift
//  AutoLayoutPiano1
//
//  Created by Erik on 2019-02-05.
//  Copyright © 2019 Erik. All rights reserved.
//

import UIKit
import AVFoundation

class PianoKey : UIButton {
    
    var timer = Timer()
    var color_r : Int
    var color_g : Int
    var color_b : Int
    var seconds : Int
    var divisor : Int
    var r_mod : Double
    var g_mod : Double
    var b_mod : Double
    
    override init(frame: CGRect) {
        color_r = 0
        color_g = 0
        color_b = 0
        
        r_mod = 4
        g_mod = 4
        b_mod = 4
        
        seconds = 5 // Fade duration
        
        divisor = (seconds * 2) * 50
        
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(colorR: Int, colorG : Int, colorB: Int) {
        color_r = colorR
        color_g = colorG
        color_b = colorB
        
        r_mod = (Double(color_r) / Double(divisor)) + 0.25
        g_mod = (Double(color_g) / Double(divisor)) + 0.25
        b_mod = (Double(color_b) / Double(divisor)) + 0.25
    }
    
    func triggerAnimation() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(fadeBackgroundToBlack), userInfo: nil, repeats: true)
    }
    
    @objc func fadeBackgroundToBlack() {
        
        self.backgroundColor = UIColor(red: CGFloat(color_r)/255, green: CGFloat(color_g)/255, blue: CGFloat(color_b)/255, alpha: 1)
        
        // Make fade curve non-linear
        let curveIncrement = 1 / Double(divisor)
        
        // Fade to black
        if color_r > 0 {
            color_r = Int(Double(color_r) - r_mod)
            r_mod = r_mod - curveIncrement // For non-linear curve
        }
        if color_g > 0 {
            color_g = Int(Double(color_g) - g_mod)
            g_mod = g_mod - curveIncrement // For non-linear curve
        }
        if color_b > 0 {
            color_b = Int(Double(color_b) - b_mod)
            b_mod = b_mod - curveIncrement // For non-linear curve
        }
        // Stop timer if black
        if color_r <= 0 && color_g <= 0 && color_b <= 0 {
            timer.invalidate()
        }
    }
}

class ViewController: UIViewController {
    
    var keysArray: [PianoKey] = []
    let tileSpacing = 0.25
    var changeOctave: Int = 0
    var soundPlayers: [AVAudioPlayer] = []
    
    let whiteKeyColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    let blackKeyColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    var octaveKeyColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove finished audio players every X seconds
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(removeUnusedPlayers), userInfo: nil, repeats: true)
        
        // Paint piano and add action targets to buttons
        renderPiano()
    }
    
    // Paint and add buttons
    func renderPiano() {
        for index in 0...16 {
            
            let button = PianoKey()
            //let screenDivBy14 = (self.view.frame.width / 14)
            let keyHeight = self.view.frame.height / 2 - CGFloat(tileSpacing)
            let keyWidth = (self.view.frame.width / 7) - CGFloat(tileSpacing * 2)
            
            // Black key row first (with spaces and octave switch keys), left to right, then white key row, left to right
            switch index {
            // octave down
            case 0:
                button.frame = CGRect(x: 0, y: self.view.frame.height / 4, width: ((self.view.frame.width / 14)) - CGFloat(tileSpacing), height: self.view.frame.height / 4 - CGFloat(tileSpacing))
                button.backgroundColor = octaveKeyColor
                button.tag = 14
                button.addTarget(self, action: #selector(octaveReset(_:)), for: .touchUpInside)
            // F#
            case 1:
                button.frame = CGRect(x: (self.view.frame.width / 14) + CGFloat(tileSpacing), y: 0, width: keyWidth, height: keyHeight)
                button.backgroundColor = blackKeyColor
                button.tag = 2
            // G#
            case 2:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 3 + CGFloat(tileSpacing), y: 0, width: keyWidth, height: keyHeight)
                button.backgroundColor = blackKeyColor
                button.tag = 4
            // A#
            case 3:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 5 + CGFloat(tileSpacing), y: 0, width: keyWidth, height: keyHeight)
                button.backgroundColor = blackKeyColor
                button.tag = 6
            // space
            case 4:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 7 + CGFloat(tileSpacing), y: 0, width: ((self.view.frame.width / 14)) - CGFloat(tileSpacing * 2), height: self.view.frame.height / 2 + CGFloat(tileSpacing))
                button.backgroundColor = whiteKeyColor
                button.tag = 15
            // space
            case 5:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 8 + CGFloat(tileSpacing), y: 0, width: ((self.view.frame.width / 14)) - CGFloat(tileSpacing * 2), height: self.view.frame.height / 2 + CGFloat(tileSpacing))
                button.backgroundColor = whiteKeyColor
                button.tag = 16
            // C#
            case 6:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 9 + CGFloat(tileSpacing), y: 0, width: keyWidth, height: keyHeight)
                button.backgroundColor = blackKeyColor
                button.tag = 9
            // D#
            case 7:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 11 + CGFloat(tileSpacing), y: 0, width: keyWidth, height: keyHeight)
                button.backgroundColor = blackKeyColor
                button.tag = 11
            // space
            case 8:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 13 + CGFloat(tileSpacing), y: 0, width: ((self.view.frame.width / 14)) - CGFloat(tileSpacing), height: self.view.frame.height / 2 + CGFloat(tileSpacing))
                button.backgroundColor = whiteKeyColor
                button.tag = 17
            // F
            case 9:
                button.frame = CGRect(x: 0, y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: (self.view.frame.width / 7) - CGFloat(tileSpacing), height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 1
            // G
            case 10:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 2 + CGFloat(tileSpacing), y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: keyWidth, height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 3
            // A
            case 11:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 4 + CGFloat(tileSpacing), y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: keyWidth, height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 5
            // B
            case 12:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 6 + CGFloat(tileSpacing), y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: keyWidth, height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 7
            // C
            case 13:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 8 + CGFloat(tileSpacing), y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: keyWidth, height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 8
            // D
            case 14:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 10 + CGFloat(tileSpacing), y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: keyWidth, height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 10
            // E
            case 15:
                button.frame = CGRect(x: (self.view.frame.width / 14) * 12 + CGFloat(tileSpacing), y: self.view.frame.height / 2 + CGFloat(tileSpacing), width: (self.view.frame.width / 7) - CGFloat(tileSpacing), height: keyHeight)
                button.backgroundColor = whiteKeyColor
                button.tag = 12
            // octave up
            case 16:
                button.frame = CGRect(x: 0, y: 0, width: ((self.view.frame.width / 14)) - CGFloat(tileSpacing), height: self.view.frame.height / 4 - CGFloat(tileSpacing * 2))
                button.backgroundColor = octaveKeyColor
                button.tag = 13
                button.addTarget(self, action: #selector(octaveReset(_:)), for: .touchUpInside)
            default:
                return
            }
            
            button.addTarget(self, action: #selector(tapHandler(_:)), for: .touchDown)
            
            keysArray.append(button) // Put in array to access properties like color etc.
            self.view.addSubview(button)
        }
        
        // Octave arrows
        let arrowUp = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        arrowUp.image = UIImage(named: "arrow_up.png")
        arrowUp.center.x = keysArray[0].frame.size.width / 2
        arrowUp.center.y = keysArray[16].frame.size.height / 2
        arrowUp.alpha = 0.1
        self.view.addSubview(arrowUp)
        
        let arrowDown = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        arrowDown.image = UIImage(named: "arrow_down.png")
        arrowDown.center.x = keysArray[0].frame.size.width / 2
        arrowDown.center.y = ((keysArray[0].frame.size.height / 2) * 3) + CGFloat(tileSpacing)
        arrowDown.alpha = 0.1
        self.view.addSubview(arrowDown)
    }
    
    // Play sounds
    @objc func tapHandler(_ sender: PianoKey) {
        
        var url = Bundle.main.url(forResource: "Samples/f", withExtension: "wav")
        let path : String = "Samples/"
        var key : String = ""
        
        switch sender.tag {
        case 1: // F
            key = "f"
        case 2: // F#
            key = "fs"
        case 3: // G
            key = "g"
        case 4: // G#
            key = "gs"
        case 5: // A
            key = "a"
        case 6: // A#
            key = "as"
        case 7: // B
            key = "b"
            animateSpaceKey(id: 4)
        case 8: // C
            key = "c"
            animateSpaceKey(id: 5)
        case 9: // C#
            key = "cs"
        case 10: // D
            key = "d"
        case 11: // D#
            key = "ds"
        case 12: // E
            key = "e"
            animateSpaceKey(id: 8)
        case 13:
            changeOctave = 1
            keysArray[16].backgroundColor = UIColor.black
        case 14:
            keysArray[0].backgroundColor = UIColor.black
            changeOctave = -1
        default:
            return
        }
        
        // Set highlight colors, different for every octave
        if sender.tag <= 12 {
            if changeOctave == 0 {
                sender.setColor(colorR: 255, colorG: 0, colorB: 0)
            } else if changeOctave == -1 {
                sender.setColor(colorR: 200, colorG: 0, colorB: 0)
            } else if changeOctave == 1 {
                sender.setColor(colorR: 255, colorG: 110, colorB: 10)
            }
        }
        
        /*
         // Random colors
        if sender.tag <= 12 {
            let random_r = Int(arc4random_uniform(256))
            let random_g = Int(arc4random_uniform(256))
            let random_b = Int(arc4random_uniform(256))
            sender.setColor(colorR: random_r, colorG: random_g, colorB: random_b)
            if sender.tag == 7 {
                keysArray[4].setColor(colorR: random_r, colorG: random_g, colorB: random_b)
                keysArray[4].triggerAnimation()
            }
            if sender.tag == 8 {
                keysArray[5].setColor(colorR: random_r, colorG: random_g, colorB: random_b)
                keysArray[5].triggerAnimation()
            }
            if sender.tag == 12 {
                keysArray[8].setColor(colorR: random_r, colorG: random_g, colorB: random_b)
                keysArray[8].triggerAnimation()
            }
        }*/
        
        // Animate
        sender.triggerAnimation()
        
        // Octave sample switch
        if changeOctave == -1 {
            key = key + "d"
        } else if changeOctave == 1 {
            key = key + "u"
        }

        // Play sound
        if sender.tag < 13 {
            do {
                // Sets path to sound
                url = Bundle.main.url(forResource: path + key, withExtension: "wav")
                // Create new sound player for every tap (timer removes finished players)
                let soundPlayer = try AVAudioPlayer(contentsOf: url!)
                soundPlayer.numberOfLoops = 0
                soundPlayer.volume = 0.5
                soundPlayer.play()
                soundPlayers.append(soundPlayer)
            } catch {
                print(error)
            }
        }
    }
    
    // Animate "space" buttons
    func animateSpaceKey(id: Int) {
        if changeOctave == 0 {
            keysArray[id].setColor(colorR: 255, colorG: 0, colorB: 0)
            keysArray[id].triggerAnimation()
        } else if changeOctave == -1 {
            keysArray[id].setColor(colorR: 200, colorG: 0, colorB: 0)
            keysArray[id].triggerAnimation()
        } else if changeOctave == 1 {
            keysArray[id].setColor(colorR: 255, colorG: 110, colorB: 10)
            keysArray[id].triggerAnimation()
        }
    }
    
    // Remove unused players
    @objc func removeUnusedPlayers() {
        for player in soundPlayers {
            if player.isPlaying { continue }
            else {
                if let index = soundPlayers.index(of: player) {
                    soundPlayers.remove(at: index)
                }
            }
        }
    }
    
    // Reset octave
    @objc func octaveReset(_ sender: UIButton) {
        changeOctave = 0
        keysArray[0].backgroundColor = octaveKeyColor
        keysArray[16].backgroundColor = octaveKeyColor
    }
}
