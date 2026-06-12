with customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

    select * from {{ ref('stg_stripe__payments') }}

),

customer_orders_payments as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(amount) as lifetime_value

    from orders
    left join payments using (order_id)

    group by 1

),


final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders_payments.first_order_date,
        customer_orders_payments.most_recent_order_date,
        coalesce(customer_orders_payments.number_of_orders, 0) as number_of_orders,
        coalesce(customer_orders_payments.lifetime_value, 0) as lifetime_value

    from customers

    left join customer_orders_payments using (customer_id)

)

select * from final
