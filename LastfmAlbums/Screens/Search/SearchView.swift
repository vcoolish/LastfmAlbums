import Foundation

protocol SearchView: class {
    func showLoading(isLoading: Bool)
    func reloadData()
    func getQueryString() -> String?
    func onRequestSuccess()
    func onRequestFail(error: String)
}
