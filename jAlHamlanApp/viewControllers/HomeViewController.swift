//
//  HomeViewController.swift
//  jAlHamlanApp
//
//  Created by Aljawhara Saleh on 08/12/1442 AH.
//

import UIKit
import Starscream

class HomeViewController: UIViewController, WebSocketDelegate{
    
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()
    
    
    
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var msg: UITextField!
    @IBOutlet weak var websocketBtn: UIButton!
    @IBOutlet weak var webSocketStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = URLRequest(url: URL(string: "wss://echo.websocket.org/")!) //https://localhost:8080
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        
        socket.disconnect()
        websocketBtn.setTitle("Connect", for: .normal)
        msg.isHidden = true
        sendMsgBtn.isHidden = true
        self.hideKeyboardWhenTappedAround()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            
            var alert = UIAlertController(title: "An issue with the network.!", message: "Please try again", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Dismiss logic here")
                
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            
            var alert = UIAlertController(title: "Message Received!", message: string, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Dismiss logic here")
                
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    
    
    
    @IBAction func WebsocketBtnIsTapped(_ sender: Any) {
        if isConnected {
            
            socket.disconnect()
            websocketBtn.setTitle("Connect", for: .normal)
            webSocketStatus.text = "Disconnected To WebSocket!"
            msg.isHidden = true
            sendMsgBtn.isHidden = true
            print("Websocket is disconnected")
            
        } else {
            
            socket.connect()
            websocketBtn.setTitle("Disconnect", for: .normal)
            webSocketStatus.text = "Connected To WebSocket!"
            msg.isHidden = false
            sendMsgBtn.isHidden = false
        }
        msg.text = ""
    }
    
    @IBAction func sendMsgViaWebsocket(_ sender: Any) {
        if msg.text != "" {
            socket.write(string: msg.text!)
            msg.text = ""
            
        }else{
            var alert = UIAlertController(title: "Empty Field", message: "You can not send an empty message", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                print("Handle Dismiss logic here")
                
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
