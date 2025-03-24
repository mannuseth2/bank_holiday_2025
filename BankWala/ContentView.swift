//
//  ContentView.swift
//  BankWal

                import SwiftUI
                import Combine

                struct Holiday: Identifiable, Codable {
                    let id = UUID()
                    let date: String
                    let localName: String
                }

                class HolidayViewModel: ObservableObject {
                    @Published var holidays: [Holiday] = []
                    private var cancellables = Set<AnyCancellable>()
                    
                    func fetchHolidays(for year: String, month: String) {
                        let urlString = "https://date.nager.at/Api/v2/PublicHolidays/\(year)/IN"
                        guard let url = URL(string: urlString) else { return }
                        
                        URLSession.shared.dataTask(with: url) { data, response, error in
                            if let data = data {
                                do {
                                    let fetchedHolidays = try JSONDecoder().decode([HolidayResponse].self, from: data)
                                        .map { Holiday(date: $0.date, localName: $0.localName) }
                                        .filter { $0.date.prefix(7) == "\(year)-\(month)" }
                                    
                                    DispatchQueue.main.async {
                                        self.holidays = fetchedHolidays
                                    }
                                } catch {
                                    print("Decoding error: \(error)")
                                }
                            }
                        }.resume()
                    }
                }

                struct HolidayResponse: Codable {
                    let date: String
                    let localName: String
                }

                struct ContentView: View {
                    @State private var selectedYear = String(Calendar.current.component(.year, from: Date()))
                    @State private var selectedMonth = "01"
                    @ObservedObject var viewModel = HolidayViewModel()
                    
                    let years = ["2023", "2024", "2025"]
                    let months = ["01": "January", "02": "February", "03": "March", "04": "April", "05": "May", "06": "June", "07": "July", "08": "August", "09": "September", "10": "October", "11": "November", "12": "December"]
                    
                    var body: some View {
                        NavigationView {
                            VStack {
                                Text("BankWala - Bank Holidays in India")
                                    .font(.title)
                                    .padding()
                                
                                Picker("Select Year", selection: $selectedYear) {
                                    ForEach(years, id: \..self) { year in
                                        Text(year)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .onChange(of: selectedYear) { newValue in
                                    viewModel.fetchHolidays(for: newValue, month: selectedMonth)
                                }
                                
                                Picker("Select Month", selection: $selectedMonth) {
                                    ForEach(months.keys.sorted(), id: \..self) { key in
                                        Text(months[key] ?? "").tag(key)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .onChange(of: selectedMonth) { newValue in
                                    viewModel.fetchHolidays(for: selectedYear, month: newValue)
                                }
                                
                                TableView(holidays: viewModel.holidays)
                            }
                            .onAppear {
                                viewModel.fetchHolidays(for: selectedYear, month: selectedMonth)
                            }
                        }
                    }
                }

                struct TableView: View {
                    let holidays: [Holiday]
                    
                    var body: some View {
                        VStack {
                            HStack {
                                Text("Date").bold().frame(width: 100, alignment: .leading)
                                Text("Holiday Name").bold().frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            
                            ScrollView {
                                ForEach(holidays) { holiday in
                                    HStack {
                                        Text(holiday.date).frame(width: 100, alignment: .leading)
                                        Text(holiday.localName).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding()
                                }
                            }
                        }
                        .border(Color.gray, width: 1)
                        .padding()
                    }
                }

                struct ContentView_Previews: PreviewProvider {
                    static var previews: some View {
                        ContentView()
                    }
                }
