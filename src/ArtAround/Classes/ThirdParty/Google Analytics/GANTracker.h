//
//  GANTracker.h
//  Google Analytics iPhone SDK.
//  Version: 1.2
//
//  Copyright 2009 Google Inc. All rights reserved.
//

extern NSString* const kGANTrackerErrorDomain;
extern NSInteger const kGANTrackerNotStartedError;
extern NSInteger const kGANTrackerInvalidInputError;
extern NSInteger const kGANTrackerEventsPerSessionLimitError;
extern NSUInteger const kGANMaxCustomVariables;
extern NSUInteger const kGANMaxCustomVariableLength;
extern NSUInteger const kGANVisitorScope;
extern NSUInteger const kGANSessionScope;
extern NSUInteger const kGANPageScope;

@protocol GANTrackerDelegate;
typedef struct __GANTrackerPrivate GANTrackerPrivate;

// Google Analytics tracker interface. Tracked pageviews and events are stored
// in a persistent store and dispatched in the background to the server.
@interface GANTracker : NSObject {
 @private
  GANTrackerPrivate *private_;

  // debug flag results in debug messages being written to the log.  Useful
  // for debugging calls to the Google Analytics SDK.
  BOOL debug_;

  // dryRun flag results in hits not actually being sent to Google Analytics.
  // Useful for testing and debugging calls to the Google Analytics SDK.
  BOOL dryRun_;
}

@property(readwrite) BOOL debug;
@property(readwrite) BOOL dryRun;

// Singleton instance of this class for convenience.
+ (GANTracker *)sharedTracker;

// Start the tracker by specifying a Google Analytics account ID and a
// dispatch period (in seconds) to dispatch events to the server
// (or -1 to dispatch manually). An optional delegate may be
// supplied.
- (void)startTrackerWithAccountID:(NSString *)accountID
                   dispatchPeriod:(NSInteger)dispatchPeriod
                         delegate:(id<GANTrackerDelegate>)delegate;

// Stop the tracker.
- (void)stopTracker;

// Track a page view. The pageURL must start with a forward
// slash '/'. Returns YES on success or NO on error (with outErrorOrNULL
// set to the specific error).
- (BOOL)trackPageview:(NSString *)pageURL
            withError:(NSError **)error;

// Track an event. The category and action are required. The label and
// value are optional (specify nil for no label and -1 or any negative integer
// for no value). Returns YES on success or NO on error (with outErrorOrNULL
// set to the specific error).
- (BOOL)trackEvent:(NSString *)category
            action:(NSString *)action
             label:(NSString *)label
             value:(NSInteger)value
         withError:(NSError **)error;

// Set a custom variable. visitor and session scoped custom variables are stored
// for later use.  Session and page scoped custom variables are attached to each
// event.  Visitor scoped custom variables are sent only on the first event for
// a session.
- (BOOL)setCustomVariableAtIndex:(NSUInteger)index
                            name:(NSString *)name
                           value:(NSString *)value
                           scope:(NSUInteger)scope
                       withError:(NSError **)error;

// Set a page scoped custom variable.  The variable set is returned with the
// next event only.  It will overwrite any existing visitor or session scoped
// custom variables.
- (BOOL)setCustomVariableAtIndex:(NSUInteger)index
                            name:(NSString *)name
                           value:(NSString *)value
                       withError:(NSError **)error;

// Returns the value of the custom variable at the index requested.  Returns
// nil if no variable is found or index is out of range.
- (NSString *)getVisitorCustomVarAtIndex:(NSUInteger)index;

// Add a transaction to the Ecommerce buffer.  If a transaction with an orderId
// of orderID is already present, it will be replaced by a new one. All
// transactions and all the items in the buffer will be queued for dispatch once
// trackTransactions is called.
- (BOOL)addTransaction:(NSString *)orderID
            totalPrice:(double)totalPrice
             storeName:(NSString *)storeName
              totalTax:(double)totalTax
          shippingCost:(double)shippingCost
             withError:(NSError **)error;

// Add an item to the Ecommerce buffer for the transaction whose orderId matches
// the input parameter orderID.  If no transaction exists, one will be created.
// If an item with the same itemSKU exists, it will be replaced with a new item.
// All the transactions and items in the Ecommerce buffer will be queued for
// dispatch once trackTransactions is called.
- (BOOL)addItem:(NSString *)orderID
        itemSKU:(NSString *)itemSKU
      itemPrice:(double)itemPrice
      itemCount:(double)itemCount
       itemName:(NSString *)itemName
   itemCategory:(NSString *)itemCategory
      withError:(NSError **)error;

// Tracks all the Ecommerce hits pending in the Ecommerce buffer.
- (BOOL)trackTransactions:(NSError **)error;

// Clears out the buffer of pending Ecommerce hits without sending them.
- (BOOL)clearTransactions:(NSError **)error;

// Manually dispatch pageviews/events to the server. Returns YES if
// a new dispatch starts.
- (BOOL)dispatch;

@end

@protocol GANTrackerDelegate <NSObject>

// Invoked when a dispatch completes. Reports the number of events
// dispatched and the number of events that failed to dispatch. Failed
// events will be retried on next dispatch.
- (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)eventsDispatched
              eventsFailedDispatch:(NSUInteger)eventsFailedDispatch;

@end
