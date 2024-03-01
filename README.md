# DoughFin_BE

## Introduction
DoughFin is a user-friendly financial management app designed to help individuals effortlessly track their income, categorize expenses, and create budgets. With DoughFin, managing your finances becomes intuitive, empowering you to make informed decisions about your money.

## Features
**Income Tracking:** Automatically track your income from various sources to see how much you're earning.<br>
**Expense Categorization:** Automatically categorize your expenses for a clearer understanding of your spending habits.<br>
**Budget Creation:** Set up personalized budgets to control your spending and achieve your financial goals.<br>
**Insightful Reports:** Get detailed reports and insights into your financial health, helping you make better financial decisions.<br>

## Endpoint Testing
[Postman Environment](https://turing-school-of-software-and-design-student-plan-team-2.postman.co/workspace/8ddf4dac-97e4-442b-8e86-5b3d49e18134)

## Database Schema
![Doughfin from DB Designer](https://github.com/DoughFin/DoughFin_BE/assets/25095319/9c9d6090-6a92-40bb-97b4-50d06c42b82a)


## Installation
ensure you have `rails@3.2.2` installed<br>
ensure you have `postgresql@14.0+` installed<br>
exec `bundle install` from project root<br>
exec `rails db:{drop,create,migrate}` to initiate database<br>
exec `rails dev:seed` to initiate dev seeds<br>
exec `rails server` to start local dev

## Testing
exec `bundle exec rspec` after you've installed the app.

## Gems
The [GraphQL](https://graphql-ruby.org/) gem was used to integrate GraphQL queries between our backend and frontend applications.

The [Shoulda Matchers Gem](https://github.com/thoughtbot/shoulda-matchers) is used for one-liner testing of models.

The [SimpleCov Gem](https://github.com/simplecov-ruby/simplecov) provides test coverage analysis for our application.

The [FactoryBot](https://github.com/thoughtbot/factory_bot) and [Faker Gems](https://github.com/faker-ruby/faker) was used to create large amounts of data for testing and rake task development. 

The [Pry gem](https://github.com/pry/pry) and [RSpec Rails](https://github.com/rspec/rspec-rails) within the testing environment for unit and feature testing.

[RSpec Benchmark](https://github.com/piotrmurach/rspec-benchmark) was used for performance testing.

## Requests and Responses
All requests are handled with POST requests, as this is the expectation for GraphQL.
### Mutations

#### Create Expense
*Back End will receive the following input:*
``` sh
mutation CreateExpense($userId: ID!, $vendor: String!, $category: String!, $amount: Float!, $date: String!) {
    createExpense(input: {
        userId: $userId,
        vendor: $vendor,
        category: $category,
        amount: $amount,
        date: $date
    }) {
        userId
        expense {
            id
            vendor
            category
            amount
            date
        }
    }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "createExpense": {
            "userId": "3",
            "expense": {
                "id": "53",
                "vendor": "Delta",
                "category": "travel",
                "amount": 10.0,
                "date": "2024-02-04"
            }
        }
    }
}
```
 
#### Create Income
*Back End will receive the following input:*
``` sh
mutation CreateIncome($userId: ID!, $source: String!, $amount: Float!, $date: String!) {
    createIncome(input: {
        userId: $userId,
        source: $source,
        amount: $amount,
        date: $date
    }) {
        userId
        income {
            source
            amount
            date
        }
    }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "createIncome": {
            "userId": "3",
            "income": {
                "source": "paycheck",
                "amount": 30.0,
                "date": "2024-02-25"
            }
        }
    }
}
```
#### Create a Budget
*Back End will receive the following input:*
``` sh
mutation CreateBudget($userId: ID!, $month: String!, $category: String!, $amount: Float!) {
    createBudget(input:
        {userId: $userId,
        month: $month,
        category: $category,
        amount: $amount}
    ) {
        userId
        budget {
            id
            month
            category
            amount
        }  
    }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "createBudget": {
            "userId": "3",
            "budget": {
                "id": "2",
                "month": "2024-02",
                "category": "utilities",
                "amount": 3500.0
            }
        }
    }
}
```

## Queries
#### Get User
*Back End will receive the following input:*
``` sh
query GetUser($email: String!) {
  user(email: $email) {
      id
      email
      username
    }
  }
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "user": {
            "id": "3",
            "email": "moneybaggins@bigbanktakelilbank.doge",
            "username": "bilbomoneybaggins"
        }
    }
}
```
 
#### Get Total Incomes
*Back End will receive the following input:*
``` sh
query GetIncomes($email: String!) {
  user(email: $email) {
      currentIncomes {
          amount
          pctChange
      }
  }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "user": {
            "currentIncomes": {
                "amount": 597036.0,
                "pctChange": 15.03118370932968
            }
        }
    }
}
```
 
#### Get Total Expenses
*Back End will receive the following input:*
``` sh
query GetExpenses($email: String!) {
  user(email: $email) {
      currentExpenses {
          amount
          pctChange
      }
  }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "user": {
            "currentExpenses": {
                "amount": 565208.0,
                "pctChange": -100.0
            }
        }
    }
}
```
 
#### Get Transactions
*Back End will receive the following input:*
``` sh
query getTransactions($email: String!) {
  user(email: $email) {
      id
      transactions {
          id
          amount
          date
          category
          vendor
          status
      }
  }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "user": {
            "id": "3",
            "transactions": [
                {
                    "id": "1",
                    "vendor": "apple",
                    "amount": 194570.0,
                    "date": "2024-02-28",
                    "status": "credited",
                    "category": "income"
                },
                {
                    "id": "23",
                    "vendor": "Rath LLC",
                    "amount": 17509.0,
                    "date": "2024-02-28",
                    "status": "debited",
                    "category": "privately held"
                },
                ...
```
 
#### Get Budgets By Params
*Back End will receive the following input:*
``` sh
query GetBudgetsByParams($month: String!, $category: String!, $email: String!) {
  user(email: $email) {
      id
      budgets(month: $month, category: $category) {
          id
          month
          category
          amount
          pctRemaining
          amountRemaining
      }
      expenses(category: $category, month: $month) {
          id
          amount
          date
          category
      }
  }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "user": {
            "id": "2",
            "budgets": [
                {
                    "id": "27",
                    "month": "2024-02",
                    "category": "Groceries",
                    "amount": 350.00,
                    "pctRemaining": 33.2,
                    "amountRemaining": 99.50
                }
            ],
            "expenses": [
                {
                    "id": "1",
                    "amount": 75.00,
                    "date": "2024-02-07",
                    "category": "Groceries"
                },
                {
                    "id": "2",
                    "amount": 125.50,
                    "date": "2024-02-15",
                    "category": "Groceries"
                }
            ]
        }
    }
}
```
 
#### Get CashFlows
*Back End will receive the following input:*
``` sh
query getCashFlow($email: String!) {
  user(email: $email) {
      id
      cashFlows {
        month
        year
        totalIncome
        totalExpense
      }
  }
}
```
*And return the following output to the front end application:*
``` sh
{
    "data": {
        "user": {
            "id": "2",
            "cashFlows": [
                {
                    "month": "February",
                    "year": 2023,
                    "totalIncome": 12500.0,
                    "totalExpense": 0.0
                },
                {
                    "month": "April",
                    "year": 2024,
                    "totalIncome": 2000.0,
                    "totalExpense": 0.0
                },
                {
                    "month": "February",
                    "year": 2024,
                    "totalIncome": 70000.0,
                    "totalExpense": 5220.0
                }
                }
            ]
        }
    }
}
```
 

## Acknowledgments
Thank you to all the contributors who have helped shape DoughFin.
Special thanks to our users for trusting us with their financial management needs.

Shawn Carpenter: [Email](shawncarpenter.co@gmail.com) [LinkedIn](https://www.linkedin.com/in/shawndcarpenter/)

Joseph Lee: [Email](jhjlee702@gmail.com)

Mary Bruff: [Email](marybruff5@gmail.com)

Taylor Pubins: [Email](tpubz@icloud.com)

Anthea Yur: [Email](acyur6@gmail.com)

Ben Rosner: [Email](ben.rosner.williamsburg@gmail.com)