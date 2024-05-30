using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using static UnityEditor.PlayerSettings;
public class DockerBarController :MonoBehaviour,IBeginDragHandler, IDragHandler,IEndDragHandler
{
    public RectTransform dockerPanel;
    public Image dockerBackground;
    Vector3 uiScreenPosition;
    Vector3 mouseScreenPosition;
    Vector3 mScreenPosition;
    private Vector3 offset;


    Camera mCamera;

    // Start is called before the first frame update
    void Start()
    {

        mCamera = Camera.main;
    }

    void Docking()
    {
        dockerPanel.position = Vector3.zero;
        dockerPanel.sizeDelta = Vector3.zero;
        dockerPanel.anchorMin = Vector2.zero;
        dockerPanel.anchorMax = Vector2.one;
        dockerPanel.anchoredPosition = Vector2.zero;
        dockerBackground.pixelsPerUnitMultiplier = 100;
    }
    public void OnBeginDrag(PointerEventData eventData)
    {

        //ת�����󵽵�ǰ��Ļλ��
        uiScreenPosition = mCamera.WorldToScreenPoint(transform.position);
        mouseScreenPosition = mCamera.WorldToScreenPoint(eventData.position);

        //�����Ļ����
        mScreenPosition = new Vector3(mouseScreenPosition.x, mouseScreenPosition.y, uiScreenPosition.z);
        //������Ͷ���֮���ƫ����,��קʱ���Ӧ�ñ��ֲ���
        offset = transform.position - mCamera.ScreenToWorldPoint(mScreenPosition);



    }

    public void OnDrag(PointerEventData eventData)
    {

        mouseScreenPosition = mCamera.WorldToScreenPoint(eventData.position);

        //�����Ļ����λ��
        mScreenPosition = new Vector3(mouseScreenPosition.x, mouseScreenPosition.y, uiScreenPosition.z);

        // ����������
        dockerPanel.position = offset + mCamera.ScreenToWorldPoint(mScreenPosition);



    }

    public void OnEndDrag(PointerEventData eventData)
    {

        if (eventData.position.x < Screen.width && eventData.position.x > 0 &&
            eventData.position.y < Screen.height && eventData.position.y > 0)
        {

        }
        else
        {
            Docking();
        }
    }

}
