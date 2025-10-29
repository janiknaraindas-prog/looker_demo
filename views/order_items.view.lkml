# The name of this view in Looker is "Order Items"



view: order_items {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.order_items`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
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
      month,
      month_num,
      month_name,
      quarter,
      year,
      day_of_month,
      day_of_year
    ]
    sql: ${TABLE}.created_at ;;
  }



  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: shipping {
    type: duration
    intervals: [
      hour,
      day,
      month
    ]
    sql_start: ${shipped_raw};;
    sql_end: ${delivered_raw} ;;
    description:"time taken for a product to be shipped to delivery"
  }
  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Inventory Item ID" in Explore.

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: status {
    type: string
    # hidden: yes
    sql: ${TABLE}.status ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }


  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  measure: latest_order_date {
    description: "latest order date (max date)"
    type: date_raw
    sql: max(${created_raw}) ;;
  }

  measure: first_order_date {
    description: "First order date (min date)"
    type: date_raw
    sql: min(${created_raw});;
  }

  measure: is_first_purchase{
    type: yesno
    sql: ${first_order_date}=${created_date} ;;
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_sale_price {
    label: "Total Sale Price"
    description: "Total sales from items sold"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }



  measure: average_sale_price {
    description: "Average sale price of items sold"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: cumulative_total_sales {
    description: "Cumulative total sales from items sold (also known as a running total)"
    type: running_total
    sql: ${total_sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    description:"Total Gross Revenue"
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "-Cancelled, -Returned"]
    value_format_name: usd
  }

  measure: total_gross_margin_amount {
    description: "Total difference between the total revenue from completed sales and the
    cost of the goods that were sold"
    type: number
    drill_fields: [product_categories_brands*,total_gross_margin_amount]
    sql: ${total_gross_revenue} - ${inventory_items.total_cost} ;;
    value_format_name: usd
  }

  dimension: count_orders {
    description: ""
    label: "Count Orders"
    type: number
  }

  measure: count_users {
    type: count_distinct
    sql: ${id} ;;
  }

  dimension: lifetime_order_tier {
    type: tier
    style: integer
    tiers: [1,2,3,5,6,9,10]
    sql: ${count_orders}  ;;
  }

  dimension: lifetime_revenue_tier {
    type: tier
    style: integer
    tiers: [0,5,20,50,100,500,1000]
    sql: ${sale_price} ;;
  }


  measure: total_lifetime_orders {
    type: sum
    sql: ${count_orders} ;;
  }
  measure: average_lifetime_orders {
    type: average
    value_format_name: decimal_2
    sql: ${count_orders} ;;
  }

  measure: total_lifetime_revenue  {
    description: "The total amount of revenue brought in over the course of customers lifetimes."
    type: sum
    sql: ${total_gross_revenue} ;;
    value_format_name: usd_0
  }

  measure: average_lifetime_revenue  {
    description: "The average amount of revenue that a customer brings in over the course of their lifetime as a customer"
    type: average
    sql: ${total_gross_revenue} ;;
    value_format_name: usd_0
  }
  dimension: repeat_customer {
    type: yesno
    sql: ${count_orders} > 1 ;;
  }

  measure: first_order {
    description: "The date in which a customer placed his or her first order on the
fashion.ly website"
    type: min
    sql: ${created_date} ;;
  }

  measure: last_order {
    description: "The date in which a customer placed his or her most recent order
on the fashion.ly website"
    type: max
    sql: ${created_date} ;;
  }






  measure: gross_margin_percent {
    description: "Total Gross Margin Amount / Total Gross Revenue"
    type: number
    drill_fields: [product_categories_items*,total_gross_margin_amount,total_gross_revenue]
    sql: 1.0*${total_gross_margin_amount}/nullif(${total_gross_revenue},0)  ;;
    value_format_name: percent_2
  }

  measure: number_items_sold {
    description: "Total number of items sold"
    type: count_distinct
    sql: ${id} ;;
  }

  measure: number_items_returned {
    label: "Number of Items Returned"
    description: "Number of items that were returned by dissatisfied customers"
    type: count_distinct
    sql: ${id} ;;
    filters: [status: "Returned"]
  }

  measure: item_return_rate {
    description: "Number of Items Returned / total number of items sold"
    type: number
    sql: 1.0*${number_items_returned} / nullif(${number_items_sold},0) ;;
    value_format_name: percent_2
  }

  measure: number_of_customers_returning_items {
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
  }

  measure: number_of_customers {
    description: "Number of users who have placed order for an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: Percent_users_with_returns {
    description: "Number of Customer Returning Items / total number of customers"
    type: number
    sql: 1.0*${number_of_customers_returning_items} / nullif(${number_of_customers},0) ;;
    value_format_name: percent_2
  }

  measure: average_spend_per_customer {
    description: "Total Sale Price / total number of customers"
    type: number
    sql: 1.0*${total_sale_price} / nullif(${number_of_customers},0) ;;
    value_format_name: usd
  }

  measure: number_of_orders {
    description: "Distinct number of orders"
    type: count_distinct
    sql: ${order_id} ;;
  }



  measure: count {
    hidden: yes
    type: count
    drill_fields: [detail*]
  }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name,
      products.name,
      products.id
    ]
  }
  set: product_categories_brands {
    fields: [
      products.category,
      products.brand
    ]
  }

  set: product_categories_items {
    fields: [
      products.category,
      products.name
    ]
  }
}
