//
//  SortPockerDataSource.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/24/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import Foundation
import UIKit

class SortPickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    let source: [PossibleSorts] = [.popularity,
                                   .priceLowHigh,
                                   .priceHighLow,
                                   .score,
                                   .companyOpinions,
                                   .productOpinions]
    
    var selectedSort = PossibleSorts.popularity     
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return source.count }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {  return source[row].rawValue.localized }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSort = source[row]
    }
}
