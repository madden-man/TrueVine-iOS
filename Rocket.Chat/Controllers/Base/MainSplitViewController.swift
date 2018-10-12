//
//  MainSplitViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 21/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class MainSplitViewController: UISplitViewController {

    let socketHandlerToken = String.random(5)

    deinit {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    static var chatViewController: ChatViewController? {
        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let mainViewController = appDelegate.window?.rootViewController as? MainSplitViewController
        else {
            return nil
        }

        var controller: ChatViewController?

        if let nav = mainViewController.detailViewController as? UINavigationController {
            if let chatController = nav.viewControllers.first as? ChatViewController {
                controller = chatController
            }
        } else if let nav = mainViewController.viewControllers.first as? UINavigationController, nav.viewControllers.count >= 2 {
            if let chatController = nav.viewControllers[1] as? ChatViewController {
                controller = chatController
            }
        }

        return controller
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ThemeManager.addObserver(self)

        delegate = self
        preferredDisplayMode = .allVisible

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
        SocketManager.reconnect()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return view.theme?.appearence.statusBarStyle ?? .default
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass,
            traitCollection.horizontalSizeClass != .compact,
            let nav = primaryViewController as? UINavigationController,
            let subscriptions = nav.viewControllers.first as? SubscriptionsViewController,
            let subscription = (detailViewController as? ChatViewController)?.subscription
        else {
            return
        }

        subscriptions.openChat(for: subscription)
    }
}

// MARK: UISplitViewControllerDelegate

extension MainSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}

// MARK: SocketConnectionHandler

extension MainSplitViewController: SocketConnectionHandler {

    func socketDidChangeState(state: SocketConnectionState) {
        if state == .waitingForNetwork || state == .disconnected {
            SocketManager.reconnect()
        }
    }

}

// MARK: Themeable

extension MainSplitViewController {
    override func applyTheme() {
        guard let theme = view.theme else { return }
        view.backgroundColor = theme.mutedAccent
        view.subviews.first?.backgroundColor = theme.mutedAccent
    }
}
