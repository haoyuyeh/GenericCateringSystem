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




struct SalesView: View {
    // MARK: Properties
    @State var title: String = ""
    @State var salesInterval: SalesInterval = .today
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    
    private var viewModel = SalesViewViewModel()
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
            
            TimeIntervalSelectionView(timeIntervalStr: $title, salesInterval: $salesInterval, startDate: $startDate, endDate: $endDate)
            
            BarChartView(salesInterval: $salesInterval, startDate: $startDate, endDate: $endDate, barChartData: viewModel.getBarChartData(for: salesInterval, startDate: startDate, endDate: endDate))
            
            Spacer()
        }
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

struct TimeIntervalSelectionView: View {
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
        Chart {
            switch salesInterval {
            case .today:
                ForEach(barChartData) { order in
                    BarMark(
                        x: .value("Order Type", order.type),
                        y: .value("Sales", order.sum),
                        stacking: .standard
                    ).foregroundStyle(by: .value("color", order.type))
                }
            default:
                ForEach(barChartData) { order in
                    BarMark(
                        x: .value("Order Type", order.date),
                        y: .value("Sales", order.sum),
                        stacking: .standard
                    ).foregroundStyle(by: .value("color", order.type))
                }
            }
        }
    }
}
