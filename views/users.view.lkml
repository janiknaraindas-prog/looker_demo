# The name of this view in Looker is "Users"

view: users {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.users`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Age" in Explore.

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_group {
    type: tier
    tiers: [15,26,36,51,66]
    style: integer
    sql: ${age} ;;
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.


  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      day_of_month,
      month,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: postal_code {
    type: string
    map_layer_name: us_zipcode_tabulation_areas
    sql: ${TABLE}.postal_code ;;
  }

  dimension: state {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.state ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }

  dimension: user_location {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude:  ${TABLE}.longitude ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension_group: hidden_today {
    hidden: yes
    type: time
    timeframes:[
      day_of_month,
      month_num
    ]
    sql: current_datetime() ;;
    datatype: datetime
  }

  dimension: is_before_month_to_date {
    description: "yes if the created date is between the first day of the month up to the current day of month. Does NOT manage the various number of days in months (28, 29, 30, 31)"
    type: yesno
    sql: ${created_day_of_month} <=${hidden_today_day_of_month}  ;;

  }

  dimension: is_customer_created_within_90_days {
    type: yesno
    sql: ${created_date} between date_sub(CURRENT_DATE(), interval 90 day) and CURRENT_DATE() ;;
  }

  dimension: days_since_signup  {
    description: "The number of days since a customer has signed up on the website"
    type: number
    sql: DATE_DIFF(current_date(), ${created_date}, day) ;;
  }

  dimension: days_since_signup_tiers {
    description: "Tiers based on days since signup"
    type: tier
    tiers: [0,30,60,90,180,366]
    style: integer
    sql: ${days_since_signup} ;;
    value_format_name: decimal_0
  }

  dimension: months_since_signup  {
    description: "The number of months since a customer has signed up on the website"
    type: number
    sql: DATE_DIFF(current_date(), ${created_date}, month) ;;
  }


  measure: new_customer_count {
    type: count
    filters: [is_customer_created_within_90_days: "Yes"]
    drill_fields: [customer_age_gender*, new_customer_count]
    description: "Count of new customers created within 90 days"
    link: {
      label: "New Customer Count by Age Group and Gender"
      url: "{{link}}&pivots=users.age_group"
    }
  }

  measure: longer_term_customer_count {
    type: count
    filters: [is_customer_created_within_90_days: "No"]
    description: "Count of new customers created more than 90 days ago"
  }

  measure: average_number_of_days_since_signup {
    description: "Average number of days between a customer initially registering on the website and now"
    type: average
    sql: ${days_since_signup} ;;
    value_format_name: decimal_0
  }

  measure: average_number_of_months_since_signup {
    description: "Average number of months between a customer initially registering on the website and now"
    type: average
    sql: ${months_since_signup} ;;
    value_format_name: decimal_0
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, order_items.count, events.count]
  }

  measure: total_age {
    type: sum
    sql: ${age} ;;
  }

  measure: average_age {
    type: average
    sql: ${age} ;;
  }


  set: customer_age_gender {
    fields: [
      age_group,
      gender
    ]
  }


}
