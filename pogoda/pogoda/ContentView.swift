import SwiftUI

struct ContentView: View {
    @State private var forecastDays: [ForecastDay] = []

    var body: some View {
        ZStack {
            Image("fon")
                            .resizable()
                          
                            .ignoresSafeArea()

            VStack {
                
                Text("Weather in Almaty")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()

                if forecastDays.isEmpty {
                  
                    ProgressView("Loading...")
                        .foregroundColor(.black)
                        .font(.title)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(forecastDays, id: \.date) { day in
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                
                                        Text(formatDate(day.date))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(day.day.condition.text)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }

                                    Spacer()
                                    AsyncImage(url: URL(string: "https:" + day.day.condition.icon)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    } placeholder: {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text("\(String(format: "%.1f", day.day.avgtemp_c))°C")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            let apiKey = "6d01aa1686ec4feb8d3181945242312"
            let city = "Almaty"
            fetchWeeklyWeather(for: city, apiKey: apiKey) { forecast in
                DispatchQueue.main.async {
                    self.forecastDays = forecast
                }
            }
        }
    }
    func formatDate(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: date) else { return date }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
func fetchWeeklyWeather(for city: String, apiKey: String, completion: @escaping ([ForecastDay]) -> Void) {
    let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(city)&days=7"
    guard let url = URL(string: urlString) else {
        completion([])
        return
        
    }
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching weather: \(error.localizedDescription)")
            completion([])
            return
        }
        guard let data = data else {
            print("No data received")
            completion([])
            return
        }
        do {
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeeklyWeatherResponse.self, from: data)
            completion(weatherResponse.forecast.forecastday)
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
            completion([])
        }
    }
    task.resume()
}
struct WeeklyWeatherResponse: Codable {
    let forecast: Forecast
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
}

struct Day: Codable {
    let avgtemp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
}
@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
