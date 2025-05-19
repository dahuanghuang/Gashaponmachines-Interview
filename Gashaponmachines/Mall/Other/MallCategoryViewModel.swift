import RxCocoa
import RxSwift

class MallCategoryViewModel: PaginationViewModel<MallProduct> {

    init(categoryId: String) {
        super.init()
        let response = request
            .flatMapLatest { page in
                AppEnvironment.current.apiService.getSortedMallProductList(categoryId: categoryId, page: page).materialize()
            }
            .share(replay: 1)

        Observable
            .combineLatest(request, response.elements(), items.asObservable()) { req, res, array in
                let responseMachines = res.products
                self.isEnd.accept(responseMachines.count < Constants.kDefaultPageLimit)
                return self.pageIndex == Constants.kDefaultPageIndex ? responseMachines : array + responseMachines
            }
            .sample(response.elements())
            .bind(to: items)
            .disposed(by: disposeBag)

        Observable
            .merge(request.map { _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: loading)
            .disposed(by: disposeBag)

        response
            .errors()
            .requestErrors()
            .bind(to: error)
            .disposed(by: disposeBag)
    }
}
