Feature: login_and_Empty_Field
      

  Scenario: Correct password entered (Twitter Manager)
    Given I am on the login page
    When I fill in "username" with "twitter-manager-sheffield"
    When I fill in "password" with "Password2!"
    When I press "log in" within "form"
    Then I go to the account page
    Then I should see "You're logged in as: twitter-manager-sheffield"
    Then I go to twittermanager page
    Then the "tweets_active" checkbox within "#column1" should not be checked
    Then the "tweets_handled" checkbox within "#column1" should not be checked
    Then I should see "Please select a conversation on the left"
    Then I should see "Conversation Details"
    Then the "branch" field within "#column3" should contain "Sheffield"
    Then the "rideOrigin" field within "#column3" should contain ""