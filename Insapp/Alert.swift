//
//  Alert.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/8/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation

enum AlertType {
    case calendarAuthorization
    case eventAdding
    case notificationEnable
    case notificationDisable
    case notificationConfirmation
    case switchPhone
    case deleteUser
    case reportComment
    case reportUser
    case reportConfirmation
}

class Alert: AnyObject {
    
    static func create(alert: AlertType, completion: ((Bool) -> ())? = nil) -> UIAlertController{
        switch alert {
        case .calendarAuthorization:
            return createCalendarAuthorizationAlert(completion)
        case .notificationEnable:
            return createNotifcationEnableAlert(completion)
        case .notificationDisable:
            return createNotifcationDisableAlert(completion)
        case .notificationConfirmation:
            return createNotificationConfirmationAlert(completion)
        case .eventAdding:
            return createEventAddingAlert(completion)
        case .switchPhone:
            return Alert.createSwitchPhoneAlert(completion)
        case .deleteUser:
            return Alert.createDeleteUserAlert(completion)
        case .reportComment:
            return Alert.createReportCommentAlert(completion)
        case .reportUser:
            return Alert.createReportUserAlert(completion)
        case .reportConfirmation:
            return Alert.createReportConfirmationAlert(completion)
        }
    }
    
    private static func createReportConfirmationAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "", message: "Un email a été envoyé à l'AEIR et au responsable d'Insapp. Une décision sera prise dans les 24h", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { alert in
            completion?(true)
        })
        alert.addAction(defaultAction)
        return alert
    }

    private static func createReportUserAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alertController = UIAlertController(title: nil, message: "Souhaites-tu signaler cet utilisateur ?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel) { (action) in
            completion?(false)
        }
        alertController.addAction(cancelAction)
        
        let badContentAction = UIAlertAction(title: "Signaler", style: .destructive) { (action) in
            completion?(true)
        }
        alertController.addAction(badContentAction)
        return alertController
    }
    
    private static func createReportCommentAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alertController = UIAlertController(title: nil, message: "Souhaites-tu signaler ce commentaire ?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel) { (action) in
            completion?(false)
        }
        alertController.addAction(cancelAction)
        
        let badContentAction = UIAlertAction(title: "Contenu non approprié", style: .destructive) { (action) in
            completion?(true)
        }
        alertController.addAction(badContentAction)
        return alertController
    }
    
    private static func createSwitchPhoneAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "Attention", message: "Ton compte est lié à un autre téléphone. Souhaites-tu changer de téléphone ? (Le compte sur l'autre téléphone sera alors déconnecté)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: { action in
            completion?(false)
        }))
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
            completion?(true)
        }))
        return alert
    }
    
    private static func createDeleteUserAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "Attention", message: "Veux tu vraiment supprimer ton compte Insapp ?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Oui", style: .destructive, handler: { action in
            completion?(true)
        }))
        return alert
    }
    
    private static func createNotifcationEnableAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "", message: "Pour activer les notifications, vas dans Réglages > Notifications > Insapp", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { alert in
            completion?(true)
        })
        alert.addAction(defaultAction)
        return alert
    }
    
    private static func createNotifcationDisableAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "", message: "Pour désactiver les notifications, vas dans Réglages > Notifications > Insapp", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(defaultAction)
        return alert
    }
    
    private static func createCalendarAuthorizationAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "Attention", message: "Pour ajouter l'évènement à ton calendrier, tu dois authoriser l'utilisation du calendrier dans les réglages du téléphone :)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return alert
    }
    
    private static func createEventAddingAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "", message: "Souhaites-tu ajouter les évènements, auxquels tu participes, à ton calendrier ?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: { action in
            completion?(false)
        }))
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
            completion?(true)
        }))
        return alert
    }
    
    private static func createNotificationConfirmationAlert(_ completion: ((Bool) -> ())?) -> UIAlertController{
        let alert = UIAlertController(title: "", message: "Les notifications ont bien été activées", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        return alert
    }
    
}
