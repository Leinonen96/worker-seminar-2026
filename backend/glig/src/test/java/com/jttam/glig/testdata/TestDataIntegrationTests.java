package com.jttam.glig.testdata;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.web.servlet.MockMvc;

import jakarta.transaction.Transactional;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class TestDataIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TestDataService testDataService;

    private Jwt jwt;

    private final String test = "auth0|69ed43f0d04d1205bb13fa9d";

    @BeforeEach
    void setUp() {
        testDataService.createAllTestData();

        jwt = Jwt.withTokenValue("token")
                .header("alg", "none")
                .claim("sub", test)
                .build();
    }

    @Test
    void ResetDataBaseToOriginalStateAfterRemovingApplies() throws Exception {

        testDataService.removeApplies();

        mockMvc.perform(get("/api/user-applications")
                .with(jwt().jwt(jwt))
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("totalElements").value(0));

        mockMvc.perform(post("/api/test-database/reset")
                .with(jwt().jwt(jwt))
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(content().string("Database reseted succesfully"));

        // After reset, auth0 user should have 10 applications from bulk test data
        mockMvc.perform(get("/api/user-applications")
                .with(jwt().jwt(jwt))
                .with(csrf()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("totalElements").value(10));
    }

    @Test
    void ResetDataBaseToOriginalStateAfterRemovingAppliesAndTasks() throws Exception {
    }

}
