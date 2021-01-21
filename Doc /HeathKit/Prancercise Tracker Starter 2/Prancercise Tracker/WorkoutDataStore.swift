/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import HealthKit

class WorkoutDataStore {
  
    class func save(prancerciseWorkout: PrancerciseWorkout,
                  completion: @escaping ((Bool, Error?) -> Void)) {
    let healthStore = HKHealthStore()
    let workoutConfiguration = HKWorkoutConfiguration()
    workoutConfiguration.activityType = .other
    if #available(iOS 12.0, *) {
        let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: workoutConfiguration,
                                       device: .local())
        builder.beginCollection(withStart: prancerciseWorkout.start) { (success, error) in
            guard success else {
            completion(false, error)
            return
            }
        }
        guard let quantityType = HKQuantityType.quantityType (
            forIdentifier: .activeEnergyBurned) else {
             completion(false, nil)
            return
        }
            
        let unit = HKUnit.kilocalorie()
        let totalEnergyBurned = prancerciseWorkout.totalEnergyBurned
        let quantity = HKQuantity(unit: unit,
                                  doubleValue: totalEnergyBurned)
        let sample = HKCumulativeQuantitySeriesSample(type: quantityType,
                                                      quantity: quantity,
                                                      start: prancerciseWorkout.start,
                                                      end: prancerciseWorkout.end)
        //1. Add the sample to the workout builder
        builder.add([sample]) { (success, error) in
          guard success else {
            completion(false, error)
            return
          }
            
          //2. Finish collection workout data and set the workout end date
            builder.endCollection(withEnd: prancerciseWorkout.end) { (success, error) in
                guard success else {
                  completion(false, error)
                  return
                }
                    
            //3. Create the workout with the samples added
            builder.finishWorkout { (_, error) in
                let success = error == nil
                completion(success, error)
            }
        }
    }
    } else {
        // Fallback on earlier versions
        
        }
    }
  
    class func loadPrancerciseWorkouts(completion:
        @escaping ([HKWorkout]?, Error?) -> Void) {
        //1. Get all workouts with the "Other" activity type.
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)

        //2. Get all workouts that only came from this app.
        let sourcePredicate = HKQuery.predicateForObjects(from: .default())

        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
        [workoutPredicate, sourcePredicate])

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                            ascending: true)
        
        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: 0,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              
              completion(samples, nil)
            }
          }

        HKHealthStore().execute(query)

    }
}
