import UIKit

public typealias ImageViewerListener = (String, ((UIViewController, UIImage?) -> ())?)

extension UIImageView {
    
    // Data holder tap recognizer
    private class TapWithDataRecognizer:UITapGestureRecognizer {
        weak var from:UIViewController?
        var imageDatasource:ImageDataSource?
        var imageLoader:ImageLoader?
        var initialIndex:Int = 0
        var options:[ImageViewerOption] = []
        var actions: [ImageViewerListener] = []
    }
    
    private var vc:UIViewController? {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController
            else { return nil }
        return rootVC.presentedViewController != nil ? rootVC.presentedViewController : rootVC
    }
    
    public func setupImageViewer(
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {
        setup(
            datasource: SimpleImageDatasource(imageItems: [.image(image)]),
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    public func setupImageViewer(
        url:URL,
        initialIndex:Int = 0,
        placeholder: UIImage? = nil,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {
        
        let datasource = SimpleImageDatasource(
            imageItems: [url].compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }
    
    public func setupImageViewer(
        images:[UIImage],
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {
        
        let datasource = SimpleImageDatasource(
            imageItems: images.compactMap {
                ImageItem.image($0)
        })
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    public func setupImageViewer(
        urls:[URL],
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        placeholder: UIImage? = nil,
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil,
        actions: [ImageViewerListener] = []
        ) {
        
        let datasource = SimpleImageDatasource(
            imageItems: urls.compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader,
            actions: actions)
    }
    
    public func setupImageViewer(
        datasource:ImageDataSource,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {
        
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }
    
    private func setup(
        datasource:ImageDataSource?,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from: UIViewController? = nil,
        imageLoader:ImageLoader? = nil,
        actions: [ImageViewerListener] = []
        ) {
        
        var _tapRecognizer:TapWithDataRecognizer?
        gestureRecognizers?.forEach {
            if let _tr = $0 as? TapWithDataRecognizer {
                // if found, just use existing
                _tapRecognizer = _tr
            }
        }
        
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        if _tapRecognizer == nil {
            _tapRecognizer = TapWithDataRecognizer(
                target: self, action: #selector(showImageViewer(_:)))
            _tapRecognizer!.numberOfTouchesRequired = 1
            _tapRecognizer!.numberOfTapsRequired = 1
        }
        // Pass the Data
        _tapRecognizer!.actions = actions
        _tapRecognizer!.imageDatasource = datasource
        _tapRecognizer!.imageLoader = imageLoader
        _tapRecognizer!.initialIndex = initialIndex
        _tapRecognizer!.options = options
        _tapRecognizer!.from = from
        addGestureRecognizer(_tapRecognizer!)
    }
    
    @objc
    private func showImageViewer(_ sender:TapWithDataRecognizer) {
        guard let sourceView = sender.view as? UIImageView else { return }
        let imageCarousel = ImageCarouselViewController.init(
            sourceView: sourceView,
            imageDataSource: sender.imageDatasource,
            imageLoader: sender.imageLoader ?? URLSessionImageLoader(),
            options: sender.options,
            initialIndex: sender.initialIndex,
            actions: sender.actions
            )
        let presentFromVC = sender.from ?? vc
        presentFromVC?.present(imageCarousel, animated: true)
    }
}
