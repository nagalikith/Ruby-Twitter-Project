Feature: Account_Manager_Previous_Rides_Offers
    Scenario: Correct password entered (Account Manager)
        Given I am on the login page
        When I fill in "username" with "accounts-manager-sheffield"
        When I fill in "password" with "Password2!"
        When I press "log in" within "form"
        Then I go to the account page
        Then I should see "You're logged in as: accounts-manager-sheffield"
        Then I go to the previousride page
        Then I fill in "username" with "josh"
        When I press "Search Rides" within "form"
        Then I should see "josh"