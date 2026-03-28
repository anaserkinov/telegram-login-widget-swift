//
//  TelegramIcon.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//

import SwiftUI

public struct TelegramIcon: Shape {

    public init() {}

    public func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 100
        let scaleY = rect.height / 100

        func pt(_ px: CGFloat, _ py: CGFloat) -> CGPoint {
            CGPoint(x: (px - 1) * scaleX, y: py * scaleY)
        }

        var path = Path()
        path.move(to: pt(88.72, 12.14))
        // C 76.42,17.24  23.66,39.09  9.08,45.05
        path.addCurve(
            to: pt(9.08, 45.05),
            control1: pt(76.42, 17.24),
            control2: pt(23.66, 39.09))
        // c -9.78,3.82  -4.05,7.39  -4.05,7.39
        path.addCurve(
            to: pt(9.08 - 4.05, 45.05 + 7.39),
            control1: pt(9.08 - 9.78, 45.05 + 3.82),
            control2: pt(9.08 - 4.05, 45.05 + 7.39))
        // s 8.35,2.86  15.5,5.01  =>  reflected control1 = (5.03,52.44)+(5.03,52.44)-(5.03,52.44) = same end
        let a = CGPoint(x: 9.08 - 4.05, y: 45.05 + 7.39)
        path.addCurve(
            to: pt(a.x + 15.5, a.y + 5.01),
            control1: pt(a.x, a.y),
            control2: pt(a.x + 8.35, a.y + 2.86))
        // c 7.15,2.15  10.97,-0.24  10.97,-0.24
        let b = CGPoint(x: a.x + 15.5, y: a.y + 5.01)
        path.addCurve(
            to: pt(b.x + 10.97, b.y - 0.24),
            control1: pt(b.x + 7.15, b.y + 2.15),
            control2: pt(b.x + 10.97, b.y - 0.24))
        // l 33.62,-22.65
        let c = CGPoint(x: b.x + 10.97, y: b.y - 0.24)
        path.addLine(to: pt(c.x + 33.62, c.y - 22.65))
        // c 11.92,-8.11  9.06,-1.43  6.2,1.43
        let d = CGPoint(x: c.x + 33.62, y: c.y - 22.65)
        path.addCurve(
            to: pt(d.x + 6.2, d.y + 1.43),
            control1: pt(d.x + 11.92, d.y - 8.11),
            control2: pt(d.x + 9.06, d.y - 1.43))
        // c -6.2,6.2  -16.45,15.98  -25.04,23.84
        let e = CGPoint(x: d.x + 6.2, y: d.y + 1.43)
        path.addCurve(
            to: pt(e.x - 25.04, e.y + 23.84),
            control1: pt(e.x - 6.2, e.y + 6.2),
            control2: pt(e.x - 16.45, e.y + 15.98))
        // c -3.82,3.34  -1.91,6.2  -0.24,7.63
        let f = CGPoint(x: e.x - 25.04, y: e.y + 23.84)
        path.addCurve(
            to: pt(f.x - 0.24, f.y + 7.63),
            control1: pt(f.x - 3.82, f.y + 3.34),
            control2: pt(f.x - 1.91, f.y + 6.2))
        // c 6.2,5.25  23.13,15.98  24.08,16.69
        let g = CGPoint(x: f.x - 0.24, y: f.y + 7.63)
        path.addCurve(
            to: pt(g.x + 24.08, g.y + 16.69),
            control1: pt(g.x + 6.2, g.y + 5.25),
            control2: pt(g.x + 23.13, g.y + 15.98))
        // c 5.04,3.57  14.94,8.7  16.45,-2.15
        let h = CGPoint(x: g.x + 24.08, y: g.y + 16.69)
        path.addCurve(
            to: pt(h.x + 16.45, h.y - 2.15),
            control1: pt(h.x + 5.04, h.y + 3.57),
            control2: pt(h.x + 14.94, h.y + 8.7))
        // c 0,0  5.96,-37.44  5.96,-37.44
        let i = CGPoint(x: h.x + 16.45, y: h.y - 2.15)
        path.addCurve(
            to: pt(i.x + 5.96, i.y - 37.44),
            control1: pt(i.x, i.y),
            control2: pt(i.x + 5.96, i.y - 37.44))
        // c 1.91,-12.64  3.82,-24.32  4.05,-27.66
        let j = CGPoint(x: i.x + 5.96, y: i.y - 37.44)
        path.addCurve(
            to: pt(j.x + 4.05, j.y - 27.66),
            control1: pt(j.x + 1.91, j.y - 12.64),
            control2: pt(j.x + 3.82, j.y - 24.32))
        // C 97.31,8.8  88.72,12.14  88.72,12.14
        path.addCurve(
            to: pt(88.72, 12.14),
            control1: pt(97.31, 8.8),
            control2: pt(88.72, 12.14))
        path.closeSubpath()

        return path
    }
}

#Preview {
    VStack {
        TelegramIcon()
            .frame(width: 64, height: 64)
            .foregroundStyle(TelegramDefaults.primaryColor)
    }
}
