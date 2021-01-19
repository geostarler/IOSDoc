# UITextFieldDelegate

Các delegate của UITextFieldDelegate: 

Khi textfield được enable, thứ tự các hàm được gọi từ lúc click vào textfield cho đến khi hoàn thành việc edit textfield sẽ là như sau: 

1. func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool:
    - Nếu return true thì sẽ cho edit textField, còn false thì không thể thực hiện việc edit.
    
2. func textFieldDidBeginEditing(_ textField: UITextField): 
    - Hàm này sẽ được gọi tới khi textField có thể edit và khi bắt đầu điền text vào textField
  
3. func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool:
    - Khi user nhập 1 ký tự từ bàn phím hoặc copy 1 đoạn text vào textfield, hàm này sẽ được gọi đến để kiểm tra text vừa nhập vào textfield.
    - Thường được sử dụng để khiến người dùng chỉ được nhập những ký tự quy định, ví dụ đoan code sau sẽ chỉ cho người dùng nhập những ký tự từ 0 đến 9:

          func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
              if textField == tfNumber {
                  let allowedCharacters = CharacterSet(charactersIn:"0123456789")
                  let characterSet = CharacterSet(charactersIn: string)
                  return allowedCharacters.isSuperset(of: characterSet)
              }
              return true
          }
          
4. @IBAction func textChanged(_ sender: UITextField): 
    - Hàm này được tạo được gán với action Edit changed của textField. Mỗi khi thay đổi text trong textField thì hàm này sẽ được gọi đến
    
5. func textFieldShouldEndEditing(_ textField: UITextField) -> Bool:
    - Nếu return true thì chúng ta có thể hoàn thành việc edit, còn false thì không thể hoàn thành được edit
    
6. func textFieldDidEndEditing(_ textField: UITextField):
    - Hàm này sẽ được gọi thì kết thúc việc edit textField

7. func textFieldShouldReturn(_ textField: UITextField) -> Bool:
    - Nếu trả về true thì sẽ cho phép sử dụng nút return trên bàn phím, còn false thì không

Extra: 
    func textFieldShouldClear(_ textField: UITextField) -> Bool: 
    - Nếu trả về true thì sẽ cho phép sử dụng nút clear trong textField, còn false thì không




