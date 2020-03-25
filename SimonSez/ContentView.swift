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
let cPublisher = PassthroughSubject<Bool, Never>()

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
  @State private var showingAlert = false
  @State var peer = ""
  @State var simonSez = ""
  @State var showSuccess = false
  @State var showFail = false
  @State var challengeBon = false
  
  
  var body: some View {
    VStack {
      Text("SimonSez").onAppear {
        //        cloud.cleanUp()
      }
      Text(code)
        .onReceive(alertPublisher, perform: { ( code ) in
          self.peer = code
          self.showingAlert = true
          self.challengeBon = true
        })
        .alert(isPresented: $showingAlert) {
          Alert(title: Text("Important message"), message: Text("Code " + self.peer), dismissButton: .default(Text("Got it!")))
      }.onReceive(cPublisher) { (_) in
        self.challengeBon = true
      }
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
              // post a copy of my token and my code
              let jsonObject: [String: Any] = ["aps":["content-available":1],"token":token!,"code":self.code]
              poster.postNotification(postTo: self.post!, jsonObject: jsonObject)
            }
        }.clipped()
          .frame(width: 128, height: 96, alignment: .center)
      }
//      Spacer(minLength: 64)
      Button(action: {
        if self.post != nil {
          let jsonObject: [String: Any] = ["aps":["content-available":1],"SimonSez":quest]
          poster.postNotification(postTo: self.post!, jsonObject: jsonObject)
          quest = ""
        }
      }) {
        Text("Challenge").alert(isPresented: $showSuccess) {
          Alert(title: Text("Important message"), message: Text("You are a Wizard"), dismissButton: .default(Text("Got it!")))
        }
      }.disabled(challengeBon)
      Button(action: {
        print("quest ",self.simonSez)
        let jsonObject: [String: Any] = ["aps":["content-available":1],"Toogle":true]
        poster.postNotification(postTo: peerToken!, jsonObject: jsonObject)
        self.challengeBon = false
        if quest == self.simonSez {
          print("cheese")
          self.showSuccess = true
          quest = ""
        } else {
          self.showFail = true
          print("fooBar")
          quest = ""
        }
      }) {
        Text("Response").onReceive(simonSezPublisher) { ( data ) in
          self.simonSez = data
        }.alert(isPresented: $showFail) {
            Alert(title: Text("Important message"), message: Text("You are a Moron"), dismissButton: .default(Text("Got it!")))
        }
      }
      HStack {
        Button(action: {
          self.animate(slice: "red")
          quest = quest + "1"
        }) { Wedge(startAngle: .init(degrees: 180), endAngle: .init(degrees: 270)) .fill(Color.red) .frame(width: 200, height: 200) .offset(x: 95, y: 95).scaleEffect(self.tLeft ? 1.1 : 1.0)
        }.onReceive(rPublisher) { (_) in
          self.animate(slice: "red")
        }
        Button(action: {
          self.animateSlice(slice: self.$tRight)
          quest = quest + "2"
        }) {
          Wedge(startAngle: .init(degrees: 270), endAngle: .init(degrees: 360)) .fill(Color.green) .frame(width: 200, height: 200) .offset(x: -95, y: 95).scaleEffect(self.tRight ? 1.1 : 1.0)
        }.onReceive(gPublisher) { (_) in
          self.animateSlice(slice: self.$tRight)
        }
      }
      HStack {
        Button(action: {
          self.animate(slice: "yellow")
          quest = quest + "3"
        }) {
          Wedge(startAngle: .init(degrees: 90), endAngle: .init(degrees: 180)) .fill(Color.yellow) .frame(width: 200, height: 200) .offset(x: 95, y: -95).scaleEffect(self.bLeft ? 1.1 : 1.0)
        }.onReceive(yPublisher) { (_) in
          self.animate(slice: "yellow")
        }
        Button(action: {
          self.animateBlue()
          quest = quest + "4"
        }) {
          Wedge(startAngle: .init(degrees: 0), endAngle: .init(degrees: 90)) .fill(Color.blue) .frame(width: 200, height: 200) .offset(x: -95, y: -95).scaleEffect(self.bRight ? 1.1 : 1.0)
        }.onReceive(bPublisher) { (_) in
          self.animateBlue()
        }
      }
    }
  }
  
  private func animate(slice: String) {
    animateAction(slice: slice)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
      self.animateAction(slice: slice)
    })
  }
  
  private func animateAction(slice: String) {
    withAnimation(.linear(duration: 0.25)){
      switch slice {
        case "red": self.tLeft.toggle()
        case "green": self.tRight.toggle()
        case "yellow": self.bLeft.toggle()
        // blue is the only other slice
        default: self.bRight.toggle()
      }
    }
  }
  
  private func animateSlice(slice: Binding<Bool>) {
          withAnimation(.linear(duration: 0.25)){
            slice.wrappedValue.toggle()
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            withAnimation(.linear(duration: 0.25)){
              slice.wrappedValue.toggle()
            }
          })
  }
  
//  private func animateSliceX(slice: String) {
//    var ptr = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
//    switch slice {
//    case "red": ptr = &tLeft
//    case "green": ptr = &tRight
//    case "yellow": ptr = &bLeft
//    default: ptr = &bRight
//    }
//    withAnimation(.linear(duration: 0.25)){
//      ptr.toggle()
//    }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
//      withAnimation(.linear(duration: 0.25)){
//        ptr.toggle()
//      }
//    })
//  }
  
//  private func animateSliceV(slice: String) {
//    switch slice {
//      case "red": DispatchQueue.main.async { rPublisher.send() }
//      case "green": gPublisher.send(); break
//      case "yellow": yPublisher.send(); break
//       blue is the only other alternative
//      default: DispatchQueue.main.async { bPublisher.send() }
//    }
//  }
  
//  private func animateSlice(slice: Bool) {
//    var sliceCopy = slice
//    withAnimation(.linear(duration: 0.25)){
//      sliceCopy.toggle()
//    }
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
//      withAnimation(.linear(duration: 0.25)){
//        sliceCopy.toggle()
//      }
//    })
//  }
  
//  private func animateRed() {
//  withAnimation(.linear(duration: 0.25)){
//    self.tLeft.toggle()
//  }
//  DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
//    withAnimation(.linear(duration: 0.25)){
//      self.tLeft.toggle()
//    }
//  })
//  }
//
//  private func animateGreen() {
//  withAnimation(.linear(duration: 0.25)){
//    self.tRight.toggle()
//  }
//  DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
//    withAnimation(.linear(duration: 0.25)){
//      self.tRight.toggle()
//    }
//  })
//  }
//
//  private func animateYellow() {
//  withAnimation(.linear(duration: 0.25)){
//    self.bLeft.toggle()
//  }
//  DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
//    withAnimation(.linear(duration: 0.25)){
//      self.bLeft.toggle()
//    }
//  })
//  }
  
  private func animateBlue() {
  withAnimation(.linear(duration: 0.25)){
    self.bRight.toggle()
  }
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
    withAnimation(.linear(duration: 0.25)){
      self.bRight.toggle()
    }
  })
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

