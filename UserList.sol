pragma solidity ^0.4.5;

import "./ID.sol";
import "./Quotation.sol";
import "./User.sol";
 
contract UserList
{
    address                         id_con_addr;
    address                         quo_con_addr;
    mapping(address => address)     user_con_map;       //�ⲿ�˻� => ��Լ�˻�
    mapping(string => address)      user_id_con_map;    //�û�id => ��Լ�˻�
    
    //���캯��
    function UserList()
    {
       id_con_addr     =       new ID_contract();
       quo_con_addr    =       new Quotation(); 
    }
    
    //�����û�
    function CreateUser(string user_id) returns(address ret)
    {
        
        address con_addr;
        
        con_addr                            =       new User(id_con_addr, quo_con_addr, this);
        user_con_map[msg.sender]            =       con_addr;
        user_id_con_map[user_id]            =       con_addr;
        
        ret                                 =       con_addr;
    }
    
    //��ѯ�û��ĺ�Լ��ַ
    function GetUserConAddr(string user_id) returns(address con_addr)
    {
        con_addr = user_id_con_map[user_id];
    }
    
     
}