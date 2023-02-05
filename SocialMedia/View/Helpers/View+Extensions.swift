//
//  View+Extensions.swift
//  SocialMedia
//
//  Created by Artem Axenov on 2023-02-03.
//

import SwiftUI

//MARK: View Extensions for UI Building
extension View {
    // Closing all active keyboards
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    //MARK: Disabling with opacity
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
//MARK: Custom border View with padding
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    //MARK: Custom fill View with padding
        func fillView(_ color: Color) -> some View {
            self
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(color)
                }
        }
}
