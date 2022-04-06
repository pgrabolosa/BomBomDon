//
//  DebugViewController.swift
//  BOAB macOS
//
//  Created by Pierre Grabolosa on 06/04/2022.
//

import SwiftUI

struct DebugView: View {
    
    @ObservedObject var labo: LaboScene
    @ObservedObject var peopleHandler: PeopleHandler
    
    @ViewBuilder var initParamsSection: some View {
        if #available(macOS 12.0, *) {
            VStack {
                Text("Initialization params")
                    .font(.title)
                    .padding(.bottom)
                
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())/*,GridItem(.flexible())*/]) {
                    ForEach(labo.config, id: \.0) { config in
                        let (bloodType, len, x, y, targetPosition) = config
                        Text(String(bloodType))
                        TextField("Length", text:.constant("\(len)"))
                        TextField("X", text:.constant("\(x)"))
                        TextField("Y", text:.constant("\(y)"))
                        //Text("\(targetPosition.x), \(targetPosition.y)")
                    }
                }.disabled(true)
            }.padding()
        } else {
            Text("Not available - required macOS 12")
        }
    }
    
    @ViewBuilder var peopleHandlerSection: some View {
        VStack {
            Text("Generation params")
                .font(.title)
                .padding(.bottom)
            
            HStack {
                Slider(value: $peopleHandler.bloodRate) { Text("🩸") }
                Text("\(Int(peopleHandler.bloodRate*100))%").font(.caption)
            }
            HStack {
                Slider(value: $peopleHandler.moneyRate) { Text("💸") }
                Text("\(Int(peopleHandler.moneyRate*100))%").font(.caption)
            }
        }.padding()
    }
    
    var body: some View {
        let width: CGFloat = 400
        let height: CGFloat = 400
        
        return ScrollView {
            initParamsSection
            peopleHandlerSection
        }
        .frame(minWidth: width, idealWidth: width, maxWidth: width, minHeight: height, idealHeight: height, maxHeight: height)
    }
}

