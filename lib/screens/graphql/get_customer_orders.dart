const String getCustomerOrders = """
query GetCustomerOrders{
  getCustomerOrders{
    orders{
      id
      orderNo
      additionalCharges
      address
      customer{
        phoneNumber
        name
        address
      }
      cartItems{
        itemStatus,
        inventory{
      id,
      name,
      originalPrice,
      sellingPrice,
      description,
      imageUrl,
      vendor{
        shopPhotoUrl,
        storeName,
        address,
        phoneNumber
      }
      category,
      deleted,
      inStock,
      date,
        }
      }
      status
      datePlaced
      updatedDate
      totalPrice
      paymentMode
      transactionSuccess
    }
    
  }
}""";
