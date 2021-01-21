//
//  InterfaceController.swift
//  HealthKitWatch Extension
//
//  Created by Nguyen Tan Dung on 21/01/2021.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var lblUserName: WKInterfaceLabel!
    @IBOutlet weak var lblHeartRate: WKInterfaceLabel!
    
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        authorizeHealthKit()
    }
    
    private enum HealthkitSetupError: Error {
      case notAvailableOnDevice
      case dataTypeNotAvailable
    }
    
    func getTodaysHeartRates() {
           //predicate
       let calendar = Calendar.current
       let now = Date()
       let components = calendar.dateComponents([.year, .month,.day], from: now)
       guard let startDate: Date = calendar.date(from: components) else { return }
       let endDate: Date? = calendar.date(byAdding: .day, value: 1, to: startDate)
       let predicate =
        HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
    
       //descriptor
       let sortDescriptors = [
                               NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                             ]

       heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                       predicate: predicate,
                                       limit: 25,
                                       sortDescriptors: sortDescriptors)
           { (query:HKSampleQuery, results:[HKSample]?, error: Error?) -> Void in
                guard error == nil else { print("error"); return }
                self.printHeartRateInfo(results: results)
           }//eo-query
       health.execute(heartRateQuery!)
   }
    
    private func printHeartRateInfo(results:[HKSample]?) {
        
        for iter in 0..<results!.count {
            guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
            lblHeartRate.setText("Heart Rate: \(currData.quantity.doubleValue(for: heartRateUnit))")
        }
    }
    
    public func fetchLatestHeartRateSample(
        completion: @escaping (_ samples: [HKQuantitySample]?) -> Void) {

        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
          .quantityType(forIdentifier: .heartRate) else {
            completion(nil)
          return
        }

        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
          .predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: .strictEndDate)

        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
          key: HKSampleSortIdentifierStartDate,
          ascending: false)

        /// Create the query
        let query = HKSampleQuery(
          sampleType: sampleType,
          predicate: predicate,
          limit: Int(HKObjectQueryNoLimit),
          sortDescriptors: [sortDescriptor]) { (_, results, error) in

            guard error == nil else {
              print("Error: \(error!.localizedDescription)")
              return
            }


            completion(results as? [HKQuantitySample])
        }
        /// Execute the query in the health store
        health.execute(query)
      }
    
    func getPermissionHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
            
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       heartRate,
                                                       bodyMass,
                                                       HKObjectType.workoutType()]
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
          completion(success, error)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func btnHearRateCount() {
//        getTodaysHeartRates()
        fetchLatestHeartRateSample { (sample) in
            self.printHeartRateInfo(results: sample)
        }
    }
    
    private func authorizeHealthKit() {
        getPermissionHealthKit {[weak self] (authorized, error) in
            
        guard authorized else {
              
          let baseMessage = "HealthKit Authorization Failed"
              
          if let error = error {
            print("\(baseMessage). Reason: \(error.localizedDescription)")
          } else {
            self?.lblHeartRate.setText("")
          }
              
          return
        }
            
        print("HealthKit Successfully Authorized.")
      }

    }
}
