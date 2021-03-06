// *************************************************** //
// Media Detail Page
//
// The media detail page is shown when a specific
// Instagram media item is displayed.
// The page has a number of features that can be
// applied to the media item as well as the user that
// uploaded it.
//
// Author: Dirk Songuer
// License: GPL v2
// See: http://choosealicense.com/licenses/gpl-v2/
// *************************************************** //

// import blackberry components
import bb.cascades 1.2
import bb.platform 1.2

// set import directory for components
import "../components"

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext
import "../classes/authenticationhandler.js" as Authentication

Page {
    id: mediaDetailPage

    // property containing the media data
    // this is filled by the calling page
    // image data is of type InstagramMediaData()
    property variant mediaData

    // main content container
    Container {
        // layout orientation
        layout: DockLayout {
        }

        // make the whole content container scrollables
        ScrollView {
            id: loginInstagramWebViewScrollContainer
            scrollViewProperties {
                scrollMode: ScrollMode.Vertical
                pinchToZoomEnabled: false
            }

            // image content
            Container {
                id: mediaDetailContainer

                // set initial visibility to false
                visible: false

                // layout orientation
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }

                // the actual detail image
                InstagramImageView {
                    id: mediaDetailImage

                    // position and layout properties
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center

                    // image was clicked
                    // call video page if media type is a video
                    onImageClicked: {
                        if (mediaData.mediaType == "video") {
                            // console.log("# Video preview image clicked");
                            mediaDetailImage.visible = false;
                            mediaDetailVideoPlayer.visible = true;
                            mediaDetailVideoPlayer.playVideo();
                        }
                    }

                    // image was double clicked
                    // add like for image by using the like button
                    // this will also check for the login state of the user
                    onImageDoubleClicked: {
                        mediaDetailLikeButton.pressButton();

                        // choose icon based on current like state
                        // note that the state has changed by now because we
                        // called pressButton() first
                        if (mediaDetailLikeButton.userHasLiked) {
                            instagoCenterToast.icon = "asset:///images/icons/icon_like.png";

                        } else {
                            instagoCenterToast.icon = "asset:///images/icons/icon_unlike.png";
                        }

                        // show toast and remove icon for next use
                        instagoCenterToast.body = "";
                        instagoCenterToast.show();
                        instagoCenterToast.icon = "";
                    }

                    // context menu for image
                    // this will be deactivated based on login state on creation
                    contextActions: [
                        ActionSet {
                            id: mediaDetailActionSet
                            title: "Image Actions"

                            // comment image action
                            ActionItem {
                                id: mediaDetailCommentImageAction
                                imageSource: "asset:///images/icons/icon_comments.png"
                                title: Copytext.instagoShowComments

                                // click action
                                onTriggered: {
                                    var mediaCommentsPage = mediaCommentsComponent.createObject();
                                    mediaCommentsPage.mediaData = mediaDetailPage.mediaData;
                                    navigationPane.push(mediaCommentsPage);
                                }

                                // shortcut for action
                                shortcuts: [
                                    Shortcut {
                                        key: "c"

                                        onTriggered: {
                                            mediaDetailCommentImageAction.triggered();
                                        }
                                    }
                                ]
                            }

                            // like image action
                            ActionItem {
                                id: mediaDetailLikeImageAction
                                imageSource: "asset:///images/icons/icon_like.png"
                                title: Copytext.instagoAddLike

                                // click action
                                onTriggered: {
                                    mediaDetailLikeButton.pressButton();
                                }

                                // shortcut for action
                                shortcuts: [
                                    Shortcut {
                                        key: "l"

                                        onTriggered: {
                                            mediaDetailLikeButton.pressButton();
                                        }
                                    }
                                ]
                            }

                            // show like list action
                            ActionItem {
                                id: mediaDetailLikeListAction
                                imageSource: "asset:///images/icons/icon_like_list.png"
                                title: Copytext.instagoShowLikes

                                // click action
                                onTriggered: {
                                    var mediaLikesPage = mediaLikesComponent.createObject();
                                    mediaLikesPage.mediaData = mediaDetailPage.mediaData;
                                    navigationPane.push(mediaLikesPage);
                                }
                            }

                            // like image action
                            ActionItem {
                                id: mediaDetailOpenLocationAction
                                imageSource: "asset:///images/icons/icon_location_dimmed.png"
                                title: Copytext.instagoOpenLocation

                                // click action
                                onTriggered: {
                                    // console.log("# Media location clicked");
                                    var mediaLocationPage = mediaLocationComponent.createObject();
                                    mediaLocationPage.mediaData = mediaDetailPage.mediaData;
                                    navigationPane.push(mediaLocationPage);
                                }
                            }

                            // open in browser
                            InvokeActionItem {
                                id: mediaDetailOpenBrowserAction

                                // query data
                                query {
                                    mimeType: "text/html"
                                    invokeActionId: "bb.action.OPEN"

                                    // note that when the url is set after creation
                                    // the query has to be updated
                                    onUriChanged: {
                                        mediaDetailOpenBrowserAction.query.updateQuery();
                                    }
                                }
                            }
                        }
                    ]
                }

                // video player
                VideoPlayer {
                    id: mediaDetailVideoPlayer

                    // set initial visibility to false
                    // will be changed by mediaDetailImage
                    visible: false
                }

                // the like and comment button
                Container {
                    // layout orientation
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }

                    // layout definition
                    topMargin: 1

                    // like button
                    // this also contains the full like functionalites
                    LikeButton {
                        id: mediaDetailLikeButton

                        // layout definition
                        rightMargin: 1

                        // position and layout properties
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }

                        // increase like count
                        onLikeAdded: {
                            mediaDetailLikeButton.count = parseInt(mediaDetailLikeButton.count) + 1;
                            mediaDetailLikeImageAction.imageSource = "asset:///images/icons/icon_unlike.png";
                            mediaDetailLikeImageAction.title = Copytext.instagoRemoveLike;
                        }

                        // decrease like count
                        onLikeRemoved: {
                            mediaDetailLikeButton.count = parseInt(mediaDetailLikeButton.count) - 1;
                            mediaDetailLikeImageAction.imageSource = "asset:///images/icons/icon_like.png";
                            mediaDetailLikeImageAction.title = Copytext.instagoAddLike;
                        }

                        // like button long pressed
                        onLongPress: {
                            // console.log("# Like button long pressed");
                            if ((Authentication.auth.isAuthenticated()) && (parseInt(mediaDetailLikeButton.count) > 0)) {
                                var mediaLikesPage = mediaLikesComponent.createObject();
                                mediaLikesPage.mediaData = mediaDetailPage.mediaData;
                                navigationPane.push(mediaLikesPage);
                            }
                        }
                    }

                    // comment button
                    // this also contains the full comment functionalites
                    CommentButton {
                        id: mediaDetailCommentButton

                        // position and layout properties
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 1.0
                        }

                        // show / hide comment input component on press
                        onClicked: {
                            mediaDetailCommentInput.visible = ! mediaDetailCommentInput.visible;
                        }

                        // comment button long pressed
                        onLongPress: {
                            // console.log("# Comment button long pressed");
                            if ((Authentication.auth.isAuthenticated()) && (parseInt(mediaDetailCommentButton.count) > 0)) {
                                var mediaCommentsPage = mediaCommentsComponent.createObject();
                                mediaCommentsPage.mediaData = mediaDetailPage.mediaData;
                                navigationPane.push(mediaCommentsPage);
                            }
                        }
                    }
                }

                CommentInput {
                    id: mediaDetailCommentInput

                    // layout definition
                    topMargin: 1

                    // set initial visibility to false
                    // will be set by comment button
                    visible: false

                    // change state of comment button if visibility of input has changed
                    onVisibleChanged: {
                        mediaDetailCommentButton.active = visible;
                    }

                    // add comment count
                    onCommentAdded: {
                        mediaDetailCommentButton.count = parseInt(mediaDetailCommentButton.count) + 1;
                        mediaDetailCommentPreview.update();
                        mediaDetailCommentButton.visible = true;
                    }
                }

                // the image description
                // this contains user profile image, name and image caption
                MediaDescription {
                    id: mediaDetailMediaDescription

                    // layout definition
                    topMargin: 1

                    onDescriptionClicked: {
                        // console.log("# Item clicked: " + mediaData.userData.userId);
                        var userDetailPage = userDetailComponent.createObject();
                        userDetailPage.userData = mediaData.userData;
                        navigationPane.push(userDetailPage);
                    }

                    onProfileClicked: {
                        // console.log("# Item clicked: " + mediaData.userData.userId);
                        var userDetailPage = userDetailComponent.createObject();
                        userDetailPage.userData = mediaData.userData;
                        navigationPane.push(userDetailPage);
                    }

                    onDescriptionUsernameClicked: {
                        // console.log("# User link clicked in description: " + username);
                        var userDetailPage = userDetailComponent.createObject();
                        userDetailPage.loadUserDataByName(username);
                        navigationPane.push(userDetailPage);
                    }

                    onDescriptionHashtagClicked: {
                        // console.log("# Hashtag link clicked in description: " + hashtag);
                        var hashtagMediaPage = mediaHashtagComponent.createObject();
                        hashtagMediaPage.hashtagSearchTerm = hashtag;
                        navigationPane.push(hashtagMediaPage);
                    }
                }

                // image location
                LocationMap {
                    id: mediaDetailLocation

                    // layout definition
                    topMargin: 1

                    // set initial visibility to false
                    // will be set true if the image has location data
                    visible: false

                    onClicked: {
                        // console.log("# Media location clicked");
                        var mediaLocationPage = mediaLocationComponent.createObject();
                        mediaLocationPage.mediaData = mediaDetailPage.mediaData;
                        navigationPane.push(mediaLocationPage);
                    }

                    // context menu for location map
                    // this will be filled with share actions later after location data has been set
                    contextActions: [
                        ActionSet {
                            id: locationHeaderActionSet
                            title: "Location Actions"

                            // invoke BB maps action
                            ActionItem {
                                id: locationBBMapsAction
                                imageSource: "asset:///images/icons/icon_location_dimmed.png"
                                title: "Open in Maps"

                                // click action
                                onTriggered: {
                                    locationBBMapsInvoker.go();
                                }
                            }
                        }
                    ]
                }

                // comment previews
                CommentPreview {
                    id: mediaDetailCommentPreview

                    // layout definition
                    topMargin: 1

                    // set specific height for component
                    // otherwise the height will be too great for some reason
                    preferredHeight: 620

                    // set initial visibility to false
                    visible: false

                    onClicked: {
                        console.log("# Comment preview clicked");

                        if (Authentication.auth.isAuthenticated()) {
                            // console.log("# Comment preview clicked");
                            var mediaCommentsPage = mediaCommentsComponent.createObject();
                            mediaCommentsPage.mediaData = mediaDetailPage.mediaData;
                            navigationPane.push(mediaCommentsPage);
                        }
                    }
                }
            }

            // check if Q series device and item is scrolled at all
            // if so, then hide / show the action bar
            onViewableAreaChanged: {
                if (DisplayInfo.height < 900)
                    if (viewableArea.y > 20) {
                    mediaDetailPage.actionBarVisibility = ChromeVisibility.Default;
                } else {
                    mediaDetailPage.actionBarVisibility = ChromeVisibility.Hidden;
                }
            }
        }

        LoadingIndicator {
            id: loadingIndicator
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }

        InfoMessage {
            id: infoMessage
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
        }
    }

    // page creation is finished
    // this prepares the general state of the page
    // the page waits for an external page to fill the mediaData property
    onCreationCompleted: {
        // console.log("# Creation of media detail page finished");

        // hide action bar if Q series device
        if (DisplayInfo.height < 900) {
            // console.log("# Display height is < 900, hiding action bar")
            actionBarVisibility:
            ChromeVisibility.Hidden;
        }

        // remove action items if user is not logged in
        if (! Authentication.auth.isAuthenticated()) {
            mediaDetailActionSet.remove(mediaDetailLikeImageAction);
            mediaDetailActionSet.remove(mediaDetailLikeListAction);
            mediaDetailActionSet.remove(mediaDetailCommentImageAction);
        }

        // show loader
        loadingIndicator.showLoader("Loading media data");
    }

    // mediaData property was changed y an external page
    // fill the detail component with the given content
    onMediaDataChanged: {
        // hide loader
        loadingIndicator.hideLoader();

        // main image
        mediaDetailContainer.visible = true;
        mediaDetailImage.url = mediaData.mediaStandardImage;
        mediaDetailImage.mediaType = mediaData.mediaType;

        if (mediaData.mediaType == "video") {
            mediaDetailVideoPlayer.videoSource = mediaData.mediaStandardVideo;
        }

        // image description (profile picture, name and image description)
        mediaDetailMediaDescription.userimage = mediaData.userData.profilePicture;
        mediaDetailMediaDescription.username = mediaData.userData.username;
        mediaDetailMediaDescription.imagecaption = mediaData.richCaption;

        // likes + comments
        mediaDetailLikeButton.count = mediaData.numberOfLikes;
        mediaDetailCommentButton.count = mediaData.numberOfComments;
        mediaDetailLikeButton.mediaId = mediaData.mediaId;
        if (mediaData.userHasLiked !== undefined) {
            mediaDetailLikeButton.userHasLiked = mediaData.userHasLiked;
        }

        // if the image has comments, show them in the preview component
        if (mediaData.commentData.length > 0) {
            mediaDetailCommentPreview.addToList(mediaData.commentData);
            mediaDetailCommentPreview.visible = true;
            mediaDetailCommentPreview.mediaId = mediaData.mediaId;
        }

        // remove action
        mediaDetailActionSet.remove(mediaDetailOpenLocationAction);

        if (mediaData.locationName != "") {
            // if the image has a location, show it in the location map component
            mediaDetailLocation.latitude = mediaData.locationLatitude;
            mediaDetailLocation.longitude = mediaData.locationLongitude;
            mediaDetailLocation.altitude = 1500;
            mediaDetailLocation.pinText = mediaData.locationName;
            mediaDetailLocation.visible = true;

            // activate location action
            mediaDetailActionSet.add(mediaDetailOpenLocationAction);

            // set data for bb maps invocation
            locationBBMapsInvoker.locationLatitude = mediaData.locationLatitude;
            locationBBMapsInvoker.locationLongitude = mediaData.locationLongitude;
            locationBBMapsInvoker.locationName = mediaData.locationName;
            locationBBMapsInvoker.centerLatitude = mediaData.locationLatitude;
            locationBBMapsInvoker.centerLongitude = mediaData.locationLongitude;
            locationBBMapsInvoker.altitude = 200;
        }

        // set browser invocation data accordingly
        if ((typeof mediaData.linkToInstagram !== "undefined") && (mediaData.linkToInstagram != "")) {
            mediaDetailOpenBrowserAction.query.uri = mediaData.linkToInstagram;
        } else {
            mediaDetailActionSet.remove(mediaDetailOpenBrowserAction);
        }
    }

    // attach components
    attachedObjects: [
        // user detail page
        // will be called if user clicks on user description
        ComponentDefinition {
            id: userDetailComponent
            source: "UserDetail.qml"
        },
        // media comments page
        // will be called if user long presses on comment button
        ComponentDefinition {
            id: mediaCommentsComponent
            source: "MediaComments.qml"
        },
        // media likes page
        // will be called if user long presses on like button
        ComponentDefinition {
            id: mediaLikesComponent
            source: "MediaLikes.qml"
        },
        // media hashtag page
        // will be called if user clicks on a hashtag in description
        ComponentDefinition {
            id: mediaHashtagComponent
            source: "HashtagMedia.qml"
        },
        // media location page
        // will be called if user clicks on location map view
        ComponentDefinition {
            id: mediaLocationComponent
            source: "LocationMedia.qml"
        },
        // map invoker
        // used to hand over location data to bb maps
        LocationMapInvoker {
            id: locationBBMapsInvoker
        }
    ]
}
