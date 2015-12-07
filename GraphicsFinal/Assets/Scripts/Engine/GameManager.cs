using UnityEngine;
using System.Collections;

public class GameManager : MonoBehaviour {

    public KeyCode quitKey = KeyCode.Escape;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        if (!Application.isEditor)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        HandleInput();

        
	}

    private void HandleInput()
    {
        if (Input.GetKeyDown(quitKey))
        {
            QuitGame();
        }
    }

    private void QuitGame() {
        Application.Quit();
    }

}
