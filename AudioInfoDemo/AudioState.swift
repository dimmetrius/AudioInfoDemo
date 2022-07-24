//
//  AudioState.swift
//  AudioInfoDemo
//
//  Created by Dzmitry Kryvalapau on 23.07.22.
//
// https://developer.apple.com/documentation/avfaudio/avaudiosession
// https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter

import Foundation
import AVFoundation
import MediaPlayer

struct AudioInfoItem: Identifiable {
    let id = UUID()
    let name: String
}

class AudioState: ObservableObject {
    
    static let didUpdateState = NSNotification.Name("didUpdateState")
    
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer
    
    // Get the default notification center instance.
    let nc = NotificationCenter.default
    
    let audioSession = AVAudioSession.sharedInstance();
    
    
    @Published var rows: [AudioInfoItem] = [];
    
    init(){
        addItem("App Started")
        subscribe();
    }
    
    deinit {
        unsubscribe();
    }
    
    func addItem(_ header: String){
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let dt = formatter.string(from: Date())
        
        // nowPlayingInfo not works as shared object
        // let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default();
        // let info = nowPlayingInfoCenter.nowPlayingInfo
        
        var info = "";
        
        if let item = musicPlayerController.nowPlayingItem {
            info = [item.albumArtist ?? "", item.albumTitle ?? "", item.title ?? ""].joined(separator: " ")
        }
        
        let name = [dt, header, info].joined(separator: "\n")
        
        self.rows.append(AudioInfoItem(name: name))
    }
    
    func subscribe() {
        
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: audioSession)
        
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
        
        nc.addObserver(self,
                       selector: #selector(handleMusicPlayerControllerNowPlayingItemDidChange),
                       name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                       object: musicPlayerController)
                
        nc.addObserver(self,
                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                       object: musicPlayerController)
        
    }
    
    func unsubscribe() {
        nc.removeObserver(self, name: AVAudioSession.interruptionNotification, object: audioSession)
        nc.removeObserver(self,
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
        
        nc.removeObserver(self,
                       name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                       object: musicPlayerController)
                
        nc.removeObserver(self,
                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                       object: musicPlayerController)
    }
    
    @objc func handleMusicPlayerControllerNowPlayingItemDidChange() {
        addItem("Playing Item Did Change.")
    }
    
    @objc func handleMusicPlayerControllerPlaybackStateDidChange() {
        addItem("Playback State Did Change.")
    }
    
    //https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            addItem("An interruption began. Update the UI as necessary.")

        case .ended:
            addItem("An interruption ended. Resume playback, if appropriate.")

            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                addItem("An interruption ended. Resume playback.")
            } else {
                addItem("An interruption ended. Don't resume playback.")
            }

        default: ()
        }
    }
    
    //https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_route_changes
    @objc func handleRouteChange(notification: Notification) {
        var headphonesConnected = false;
        
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        
        // Switch over the route change reason.
        switch reason {

        case .newDeviceAvailable: // New device found.
            let session = AVAudioSession.sharedInstance()
            headphonesConnected = hasHeadphones(in: session.currentRoute)
            addItem("new Device Available");
        
        case .oldDeviceUnavailable: // Old device removed.
            addItem("old Device Unavailable");
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                headphonesConnected = hasHeadphones(in: previousRoute)
            }
        
        default: ()
        }
    }

    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
}
