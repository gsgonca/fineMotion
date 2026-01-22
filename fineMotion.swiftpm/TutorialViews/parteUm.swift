//
//  parteUm.swift
//  fineMotion
//
//  Created by Gabriel Santos Gonçalves on 22/01/26.
//

import SwiftUI

struct parteUm: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Wellcome to Fine Motion!")
                    .font(.title2.bold())
                    .padding()
                    .foregroundStyle(Color.accentColor)
                
                Text("It's time to improve your pinch precision.\n\nPlace your thumb and index fingers above the blue controllers.\n\nDo your best to follow the lines with both fingers, mirroring a pinch with your hand")
                    .font(.title3)
            }
            .padding(16)
        }
    }
}

#Preview {
    parteUm()
}
