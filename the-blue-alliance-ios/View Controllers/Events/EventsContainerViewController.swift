import Foundation
import UIKit
import CoreData
import FirebaseRemoteConfig

class EventsContainerViewController: ContainerViewController {

    private let remoteConfig: RemoteConfig
    private let urlOpener: URLOpener

    private(set) var year: Int
    private(set) var eventsViewController: WeekEventsViewController

    // MARK: - Init

    init(remoteConfig: RemoteConfig, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.remoteConfig = remoteConfig
        self.urlOpener = urlOpener

        year = remoteConfig.currentSeason
        eventsViewController = WeekEventsViewController(year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [eventsViewController],
                   persistentContainer: persistentContainer,
                   tbaKit: tbaKit,
                   userDefaults: userDefaults)

        title = "Events"
        tabBarItem.image = UIImage(named: "ic_event")
        updateInterface()

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        eventsViewController.weekEventsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func updateInterface() {
        if let weekEvent = eventsViewController.weekEvent {
            navigationTitle = "\(weekEvent.weekString) Events"
            navigationSubtitle = "▾ \(weekEvent.year!.intValue)"
        } else {
            navigationTitle = "---- Events"
            navigationSubtitle = "▾ \(year)"
        }
    }

}

extension EventsContainerViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        let yearSelectViewController = YearSelectViewController(year: year, years: Array(1992...remoteConfig.maxSeason).reversed(), week: eventsViewController.weekEvent, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        yearSelectViewController.delegate = self

        let nav = UINavigationController(rootViewController: yearSelectViewController)
        navigationController?.present(nav, animated: true, completion: nil)
    }

}

extension EventsContainerViewController: YearSelectViewControllerDelegate {

    func weekEventSelected(_ weekEvent: Event) {
        year = weekEvent.year!.intValue
        eventsViewController.weekEvent = weekEvent
    }

}

extension EventsContainerViewController: WeekEventsDelegate {

    func weekEventUpdated() {
        updateInterface()
    }

}

extension EventsContainerViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        // Show detail wrapped in a UINavigationController for our split view controller
        let eventViewController = EventViewController(event: event, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: eventViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}
