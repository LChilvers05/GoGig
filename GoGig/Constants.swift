//
//  Constants.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation

//MARK: SEGUES

let TO_CREATE_PROFILE = "toCreateProfile"
let TO_EDIT_PROFILE = "toEditProfile"
let TO_SOCIAL_LINKS = "toSocialLinks"
let TO_MUSIC_LINKS = "toMusicLinks"
let TO_MAIN = "toMain"
let TO_MAIN_2 = "toMain2"

let TO_CREATE_GIG = "toCreateGig"
let TO_EDIT_GIG_EVENT = "toEditGigEvent"
let TO_TITLE_DATE = "toTitleDate"
let TO_LOCATION_PRICING = "toLocationPricing"
let TO_INFO_CONTACT = "toInfoContact"
let TO_ADD_PHOTO = "toAddPhoto"

let TO_FIND_GIG = "toFindGig"
let TO_EVENT_DESCRIPTION = "toEventDescription"
let TO_EVENT_DESCRIPTION_2 = "toEventDescription2"

let TO_CHECK_PORTFOLIO = "toCheckPortfolio"
let TO_CHECK_PORTFOLIO_2 = "toCheckPortfolio2"
let TO_CHECK_PORTFOLIO_3 = "toCheckPortfolio3"
let TO_REVIEW_APPLICATION = "toReviewApplication"


// User Defaults

let DEFAULTS = UserDefaults.standard

let LOGGED_IN_KEY = "loggedIn"
let USER_EMAIL = "userEmail"


//MARK: GLOBAL VARIABLES

//Sign In/Out Gates
var tabGateOpen = true
var accountGateOpen = true
var cardGateOpen = true
var feedGateOpen = true
var observeGateOpen = true
var paginationGateOpen = true
var pushNotificationGateOpen = true


var launchedFromNotification = false
var editingProfile = false
var editingGigEvent = false



