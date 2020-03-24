//
//  ContentView.swift
//  SimonSez
//
//  Created by localadmin on 24.03.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let crypto = Crypto()
let cloud = Storage()
let poster = RemoteNotifications()

let   playPublisher = PassthroughSubject<[rex], Never>()
let rPublisher = PassthroughSubject<Void, Never>()
let gPublisher = PassthroughSubject<Void, Never>()
let yPublisher = PassthroughSubject<Void, Never>()
let bPublisher = PassthroughSubject<Void, Never>()

class nouvelleUsers: ObservableObject {
  var rexes:[rex] = []
}

struct ContentView: View {
  @State var code = "" {
    didSet {
      coder = self.code
    }
  }
  @State var selected = 0
  @State var nouvelle = nouvelleUsers()
  @State var display = false
  @State var color = Color.red
  @State var tLeft = false
  @State var tRight = false
  @State var bLeft = false
  @State var bRight = false
  @State var post:String? = ""
  
  
  var body: some View {
    VStack {
      Text("SimonSez").onAppear {
        //        cloud.cleanUp()
      }
      Text(code)
      Spacer()
      Button(action: {
        if self.code == "" {
          self.code = crypto.genCode()!
          if token != nil {
            cloud.saveCode(randomCode: self.code, token: token)
          } else {
            print("Dead ...")
            cloud.refreshCodes()
          }
        } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cloud.refreshCodes()
          }
        }
      }) {
        Text("Play")
      }.onReceive(playPublisher) { ( data ) in
        self.display = false
        self.nouvelle.rexes = data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
          self.display = true
        })
        
      }
      Spacer()
      if display {
        Picker(selection: self.$selected, label: Text("")) {
          ForEach(0 ..< self.nouvelle.rexes.count) {dix in
            Text(self.nouvelle.rexes[dix].id!)
            
          }
        }.pickerStyle(WheelPickerStyle())
          .onTapGesture {
            if self.nouvelle.rexes.count > 0 {
              print("play ",self.nouvelle.rexes[self.selected].token!)
              self.post = self.nouvelle.rexes[self.selected].token!
            }
        }.clipped()
          .frame(width: 128, height: 96, alignment: .center)
      }
      Spacer(minLength: 64)
      Button(action: {
        if self.post != nil {
          poster.postNotification(postTo: self.post!)
        }
      }) {
        Text("Challenge")
      }
      HStack {
        Button(action: {
          withAnimation(.linear(duration: 0.25)){
            self.tLeft = !self.tLeft
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.tLeft = !self.tLeft
            }
          })
          quest = quest + "1"
        }) { Wedge(startAngle: .init(degrees: 180), endAngle: .init(degrees: 270)) .fill(Color.red) .frame(width: 200, height: 200) .offset(x: 95, y: 95).scaleEffect(self.tLeft ? 1.1 : 1.0)
        }.onReceive(rPublisher) { (_) in
          withAnimation(.linear(duration: 0.25)){
            self.tLeft.toggle()
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.tLeft.toggle()
            }
          })
        }
        Button(action: {
          withAnimation(.linear(duration: 0.25)){
            self.tRight = !self.tRight
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.tRight = !self.tRight
            }
          })
          quest = quest + "2"
        }) {
          Wedge(startAngle: .init(degrees: 270), endAngle: .init(degrees: 360)) .fill(Color.green) .frame(width: 200, height: 200) .offset(x: -95, y: 95).scaleEffect(self.tRight ? 1.1 : 1.0)
        }.onReceive(gPublisher) { (_) in
          withAnimation(.linear(duration: 0.25)){
            self.tRight = !self.tRight
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.tRight = !self.tRight
            }
          })
        }
      }
      HStack {
        Button(action: {
          withAnimation(.linear(duration: 0.25)){
            self.bLeft = !self.bLeft
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.bLeft = !self.bLeft
            }
          })
          quest = quest + "3"
        }) {
          Wedge(startAngle: .init(degrees: 90), endAngle: .init(degrees: 180)) .fill(Color.yellow) .frame(width: 200, height: 200) .offset(x: 95, y: -95).scaleEffect(self.bLeft ? 1.1 : 1.0)
        }.onReceive(yPublisher) { (_) in
          withAnimation(.linear(duration: 0.25)){
            self.bLeft = !self.bLeft
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.bLeft = !self.bLeft
            }
          })
        }
        Button(action: {
          withAnimation(.linear(duration: 0.25)){
            self.bRight = !self.bRight
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.bRight = !self.bRight
            }
          })
          quest = quest + "4"
        }) {
          Wedge(startAngle: .init(degrees: 0), endAngle: .init(degrees: 90)) .fill(Color.blue) .frame(width: 200, height: 200) .offset(x: -95, y: -95).scaleEffect(self.bRight ? 1.1 : 1.0)
        }.onReceive(bPublisher) { (_) in
          withAnimation(.linear(duration: 0.25)){
            self.bRight = !self.bRight
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              self.bRight = !self.bRight
            }
          })
        }
      }
    }
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct Wedge: Shape {
  let startAngle: Angle
  let endAngle: Angle
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let center = CGPoint(x: rect.midX, y: rect.midY)
    path.addArc( center: center, radius: min(rect.midX, rect.midY), startAngle: startAngle, endAngle: endAngle, clockwise: false )
    path.addLine(to: center)
    path.closeSubpath()
    return path } }

