package com.jttam.glig.domain.user;

import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.jttam.glig.domain.common.ProfileStatus;
import com.jttam.glig.domain.employerprofile.EmployerProfile;
import com.jttam.glig.domain.employerprofile.EmployerProfileRepository;
import com.jttam.glig.domain.employerprofile.EmployerType;
import com.jttam.glig.domain.taskerprofile.TaskerProfile;
import com.jttam.glig.domain.taskerprofile.TaskerProfileRepository;
import com.jttam.glig.domain.user.dto.UserRequest;
import com.jttam.glig.domain.user.dto.UserResponse;
import com.jttam.glig.exception.custom.NotFoundException;
import com.jttam.glig.service.Message;
import org.springframework.security.oauth2.jwt.Jwt;

import jakarta.transaction.Transactional;

@Service
public class UserControllerService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final TaskerProfileRepository taskerProfileRepository;
    private final EmployerProfileRepository employerProfileRepository;

    public UserControllerService(UserRepository userRepository, UserMapper userMapper,
            TaskerProfileRepository taskerProfileRepository,
            EmployerProfileRepository employerProfileRepository) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.taskerProfileRepository = taskerProfileRepository;
        this.employerProfileRepository = employerProfileRepository;
    }

    public User findUserByGivenUserName(String username) {
        User user = userRepository.findByUserName(username)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Cannot find user by given jwt"));
        return user;
    }

    @Transactional
    public UserResponse tryGetSingleUserDtoByUserName(String username) {
        // Get or create user if they don't exist (handles legacy Auth0 users)
        User user = userRepository.findByUserName(username)
                .orElseGet(() -> {
                    // Create minimal user entity for Auth0 users without database records
                    User newUser = new User();
                    newUser.setUserName(username);
                    newUser.setMail(""); // Will be updated when user edits profile
                    User created = userRepository.save(newUser);
                    
                    // Create default empty TaskerProfile
                    TaskerProfile taskerProfile = new TaskerProfile();
                    taskerProfile.setUser(created);
                    taskerProfile.setStatus(ProfileStatus.ACTIVE);
                    taskerProfileRepository.save(taskerProfile);
                    
                    // Create default empty EmployerProfile
                    EmployerProfile employerProfile = new EmployerProfile();
                    employerProfile.setUser(created);
                    employerProfile.setEmployerType(EmployerType.INDIVIDUAL);
                    employerProfile.setStatus(ProfileStatus.ACTIVE);
                    employerProfileRepository.save(employerProfile);
                    
                    return created;
                });
        
        UserResponse userDto = userMapper.toUserResponse(user);
        return userDto;
    }

    @Transactional
    public User getOrCreateUser(Jwt jwt) {
        String username = jwt.getSubject();
        String claimEmail = jwt.getClaimAsString("email");
        
        // This sets the variable once, making it "effectively final"
        final String email = (claimEmail == null || claimEmail.isBlank()) 
                         ? username + "@glig.com" 
                         : claimEmail;

        return userRepository.findByUserName(username)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setUserName(username);
                    newUser.setMail(email); // Lambda is happy now!
                    User created = userRepository.save(newUser);

                    TaskerProfile tp = new TaskerProfile();
                    tp.setUser(created);
                    tp.setStatus(ProfileStatus.ACTIVE);
                    taskerProfileRepository.save(tp);

                    EmployerProfile ep = new EmployerProfile();
                    ep.setUser(created);
                    ep.setEmployerType(EmployerType.INDIVIDUAL);
                    ep.setStatus(ProfileStatus.ACTIVE);
                    employerProfileRepository.save(ep);

                    return created;
                });
    }

    @Transactional
    public ResponseEntity<?> tryCreateNewUser(UserRequest userBody, String username) {
        Optional<User> user = userRepository.findByUserName(username);
        if (user.isPresent()) {
            return new ResponseEntity<>(new Message("ERROR", "User already exists"), HttpStatus.CONFLICT);
        }
        User newUser = userMapper.toUserEntity(userBody);
        newUser.setUserName(username);
        User created = userRepository.save(newUser);
        
        // Create default empty TaskerProfile
        TaskerProfile taskerProfile = new TaskerProfile();
        taskerProfile.setUser(created);
        taskerProfile.setStatus(ProfileStatus.ACTIVE);
        taskerProfileRepository.save(taskerProfile);
        
        // Create default empty EmployerProfile
        EmployerProfile employerProfile = new EmployerProfile();
        employerProfile.setUser(created);
        employerProfile.setEmployerType(EmployerType.INDIVIDUAL); // Default to INDIVIDUAL
        employerProfile.setStatus(ProfileStatus.ACTIVE);
        employerProfileRepository.save(employerProfile);
        
        UserResponse out = userMapper.toUserResponse(created);
        return new ResponseEntity<>(out, HttpStatus.CREATED);
    }

    @Transactional
    public ResponseEntity<UserResponse> tryEditUser(UserRequest userBody, String username) {
        User user = findUserByGivenUserName(username);
        User updatedUser = userMapper.updateUser(userBody, user);
        User created = userRepository.save(updatedUser);
        UserResponse out = userMapper.toUserResponse(created);

        return new ResponseEntity<>(out, HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<UserResponse> tryDeleteUser(String username) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'tryDeleteUser'");
    }
}