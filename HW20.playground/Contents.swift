import UIKit

// MARK: - Struct with URL

struct CardURL {
    enum CardName: String {
        case opt
        case blackLotus = "black_lotus"
        case twoCards = "opt|black_lotus"
    }
    
    private var components = URLComponents()
    
    private let scheme = "https"
    private let host = "api.magicthegathering.io"
    private let path = "/v1/cards"
    private let queryName = "name"
    private let queryValue: CardName
    
    init(with name: CardName) {
        queryValue = name
        setURL()
    }
    
    private mutating func setURL() {
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem(name: queryName, value: queryValue.rawValue)]
    }
    
    public func getURL() -> URL? {
        components.url
    }
}

// MARK: - Decodable Model

struct Cards: Decodable {
    let cards: [Card]
}

struct Card: Decodable {
    let name: String
    let manaCost: String?
    let rarity: String
    let setName: String
    let type: String
    let cmc: Double
}

// MARK: - Get data method

func getData(urlRequest: URL?) {
    guard let url = urlRequest else { return }
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let response = response as? HTTPURLResponse else {
            print("Проблемы с сетью")
            return
        }
        switch response.statusCode {
        case 200:
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(Cards.self, from: data)
                printer(cards: decoded.cards)
            } catch {
                print("Ошибка при декодировке JSON")
            }
        default:
            if let error = error {
                print("Ошибка \(error.localizedDescription)")
            } else {
                print("Статус код запроса - \(response.statusCode)")
            }
        }
    }.resume()
}

// MARK: - Printer

func printer(cards: [Card]?) {
    guard let cards = cards else { return }
    for card in cards {
        if var manacost = card.manaCost {
            manacost = manacost.filter { $0 != "{" && $0 != "}" }
            print("""
                Название карты - \(card.name)
                Стоимость - \(manacost)
                Тип - \(card.type)
                Редкость - \(card.rarity)
                Название набора - \(card.setName)\n
                """
            )
        }
    }
}

// MARK: - Instances and Data responces

let blackLotusURL = CardURL(with: .blackLotus).getURL()
let optURL = CardURL(with: .opt).getURL()
let twoNames = CardURL(with: .twoCards).getURL()

//getData(urlRequest: blackLotusURL)
//getData(urlRequest: optURL)
getData(urlRequest: twoNames)


