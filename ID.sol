pragma solidity ^0.4.5;



contract ID_contract
{
    string      user_id_;       //�ͻ�id
    uint        receipt_id_;    //�ֵ�id
    uint        con_id_;        //��ͬid
    uint        neg_id_;   //Э��id
    
    //������ͬid
    function contract_id() returns(uint )
    {
        return ++con_id_;
    }
    
    //����Э�̽��ױ��
    function negotiate_id() returns(uint )
    {
        return  ++neg_id_;
    }
}