# If necessary, uncomment the line below to include explore_source.

# include: "jani_usecase.model.lkml"

view: customer_lifetime_measure {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: total_gross_revenue {}
    }
  }
  dimension: user_id {
    primary_key: yes
    description: ""
    type: number
  }
  dimension: total_gross_revenue {
    description: "Total Gross Revenue"
    value_format: "$#,##0.00"
    type: number
  }
  measure: customer_lifetime_revenue {
    description: "Customer Lifetime Revenue"
    type: sum
    sql: (${total_gross_revenue});;
  }

}
