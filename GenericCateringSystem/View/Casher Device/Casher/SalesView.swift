//
//  SalesView.swift
//  GenericCateringSystem
//
//  Created by Hao Yu Yeh on 2024/5/16.
//

import SwiftUI
import Charts

class SalesData: Identifiable {
    var id: UUID
    var date: String
    var type: String
    var sum: Double
    
    init(id: UUID = UUID(), date: String = "", type: String = "", sum: Double = 0.0) {
        self.id = id
        self.date = date
        self.type = type
        self.sum = sum
    }
}

struct YellowGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(.top, 30)
            .padding(20)
            .background(Color(hue: 0.10, saturation: 0.10, brightness: 0.98))
            .cornerRadius(20)
    }
}

struct SalesView: View {
    // MARK: Properties
    @State var title: String = "Today's Sales"
    @State var salesInterval: SalesInterval = .today
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        GeometryReader { view in
            let graphWidth = view.size.width * 0.9
            let graphHeight = view.size.height * 0.4
            
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    Spacer()
                    TimeIntervalView(timeIntervalStr: $title, salesInterval: $salesInterval, startDate: $startDate, endDate: $endDate)
                }
                
                Text(title)
                    .font(.largeTitle)
                
                GroupBox {
                    HStack {
                        Spacer()
                        BarChartView(salesInterval: $salesInterval, startDate: $startDate, endDate: $endDate, barChartData: SalesViewViewModel.shared.getBarChartData(for: salesInterval, startDate: startDate, endDate: endDate))
                        Spacer()
                    }
                }
                .groupBoxStyle(YellowGroupBoxStyle())
                .frame(width: graphWidth, height: graphHeight)
                
                Spacer()
                
                if salesInterval != SalesInterval.today {
                    GroupBox {
                        HStack {
                            Spacer()
                            
                            LineChartView(startDate: $startDate, endDate: $endDate, barChartData: SalesViewViewModel.shared.getBarChartData(for: salesInterval, startDate: startDate, endDate: endDate))
                            Spacer()
                        }
                    }
                    .groupBoxStyle(YellowGroupBoxStyle())
                    .frame(width: graphWidth, height: graphHeight)
                }
            }
        }
        Spacer()
    }
}


#Preview {
    SalesView()
}

extension View {
    @ViewBuilder func isHidden(value: Bool) -> some View {
        if value {
            self.hidden()
        }else {
            self
        }
    }
}

struct TimeIntervalView: View {
    @Binding var timeIntervalStr: String
    @Binding var salesInterval: SalesInterval
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State var isTimeIntervalMode: Bool = false
    
    var body: some View {
        HStack {
            Menu {
                Button {
                    isTimeIntervalMode = false
                    timeIntervalStr = "Today's Sales"
                    salesInterval = .today
                } label: {
                    Text("Today")
                }
                
                Button {
                    isTimeIntervalMode = false
                    timeIntervalStr = "Weekly Sales"
                    salesInterval = .weekly
                } label: {
                    Text("Weekly")
                }
                
                Button {
                    isTimeIntervalMode = false
                    timeIntervalStr = "Monthly Sales"
                    salesInterval = .monthly
                } label: {
                    Text("Monthly")
                }
                
                Button {
                    isTimeIntervalMode = true
                    timeIntervalStr = "\(startDate.formatted(date: .numeric, time: .omitted))  ~  \(endDate.formatted(date: .numeric, time: .omitted))"
                    salesInterval = .interval
                } label: {
                    Text("Time Interval")
                }
            } label: {
                Text("Sales Range")
            }.menuOrder(.fixed)
                .padding()
                .font(.headline)
            HStack {
                Text("From")
                    .fixedSize()
                DatePicker("", selection: $startDate, in: ...endDate, displayedComponents: .date)
                    .fixedSize()
                    .onChange(of: startDate){
                        timeIntervalStr = "\(startDate.formatted(date: .numeric, time: .omitted))  ~  \(endDate.formatted(date: .numeric, time: .omitted))"
                    }
                Text("To")
                    .fixedSize()
                DatePicker("", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                    .fixedSize()
                    .onChange(of: endDate){
                        timeIntervalStr = "\(startDate.formatted(date: .numeric, time: .omitted))  ~  \(endDate.formatted(date: .numeric, time: .omitted))"
                    }
            }.isHidden(value: !isTimeIntervalMode)
            
            Spacer()
        }
    }
}

struct BarChartView: View {
    @Binding var salesInterval: SalesInterval
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var barChartData: [SalesData]
    
    
    var body: some View {
        switch salesInterval {
        case .today:
            Chart {
                ForEach(barChartData) { order in
                    BarMark(
                        x: .value("Order Type", order.type),
                        y: .value("Sales", order.sum),
                        stacking: .standard
                    )
                    .foregroundStyle(by: .value("color", order.type))
                    .annotation {
                        Text("$\(String(format:"%.1f", order.sum))")
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            
        default:
            
            Chart {
                ForEach(barChartData) { order in
                    BarMark(
                        x: .value("Date", order.date),
                        y: .value("Sales", order.sum)
                    )
                    .foregroundStyle(by: .value("color", order.type))
                    .annotation(position: .overlay) {
                        Text("$\(String(format:"%.1f", order.sum))")
                    }
                    .annotation {
                        let sum = SalesViewViewModel.shared.getSales(of: order.date, from: barChartData)
                        Text("$\(String(format:"%.1f", sum))")
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 7)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}

struct LineChartView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var barChartData: [SalesData]
    
    var body: some View {
        Chart {
            ForEach(barChartData) { order in
                LineMark(
                    x: .value("Date", order.date),
                    y: .value("Sales", order.sum)
                )
                .foregroundStyle(by: .value("type", order.type))
                .symbol(by: .value("type", order.type))
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 7)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
