//
//  Use.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/14.
//

import SwiftUI
import AVKit

struct Use: View {
    let next: () -> Void
    var body: some View {
        VStack {
            Text("""
            Loading notion data
            """)
                .font(.title)
                .bold()
                .padding(.top)
            Image("notion")
                .resizable()
                .frame(width: 500, height: 500)
            Button{
                next()
            }label: {
                Text("Load")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        #if os(iOS)
        .padding(.top, 40)
        #endif
    }
}

struct UsePreviews: PreviewProvider {
    static var previews: some View {
        Use{}
    }
}
