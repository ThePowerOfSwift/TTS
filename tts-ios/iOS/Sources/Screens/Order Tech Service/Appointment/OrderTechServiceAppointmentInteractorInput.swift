//
//  OrderTechServiceAppointmentInteractorInput.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

protocol OrderTechServiceAppointmentInteractorInput {
    
    var submitButtonTitle: String { get }
    
    func observeData(onNext: @escaping (OrderTechServiceAppointmentDTO?) -> Void)
    
    func sendData(completion: @escaping (Error?) -> Void)
    
}
