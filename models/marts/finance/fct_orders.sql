with orders as (
    select
        order_id,
        customer_id
    from {{ ref('stg_jaffle_shop__orders') }}
),

payments as (
    select
        payment_id,
        order_id,
        amount,
        status
    from {{ ref('stg_stripe__payments') }}
),

order_payments as (
    select
        order_id,
        sum(case when payments.status = 'success' then payments.amount else 0 end) as amount
    from payments
    group by 1
),

final as (
    select

    orders.order_id,
    orders.customer_id,
    order_payments.amount

    from orders
    left join order_payments using (order_id)

)

select * from final